import sys

import requests

from workflow import PasswordNotFound

import utils
from okta_auth import OktaAuth, get_okta_keychain_key

BASE_PRODLOGIN_URL = "https://private.hubteam%s.com/prodlogin/auth/%s"
GITHUB_ACCESS_TOKEN_MSG = "Enter your GitHub Personal Access Token for Alfred.\n\nVisit HubSpot/alfred-hubspotdev-tools for instructions."
DUO_2FA_MSG = "  Options:\n    - Press enter for a Duo Push (leave input blank)\n    - Enter a Duo OTP then press enter\n    - Activate your YubiKey\n"


class TokenException(Exception):
    pass


class TwoFAException(TokenException):
    pass


class InvalidOTPException(TokenException):
    pass


class VPNException(Exception):
    pass


class Auth(object):
    def __init__(self, wf):
        self.wf = wf

    def ldap(self, clear=False):
        return self.user_pass("ldap", "PROD (Janus)", None, clear)

    def corp(self, clear=False):
        return self.user_pass("corp", "CORP (Okta)", None, clear)

    def prodlogin(self, env, clear=False, otp=None):
        if clear:
            try:
                self.wf.delete_password('prodlogin%s' % env)
            except PasswordNotFound:
                pass

        try:
            token = self.wf.get_password('prodlogin%s' % env)

        except PasswordNotFound:
            try:
                signed_duo_txid_token = self.get_signed_duo_txid_token(env)
                token = self.generate_prodlogin_token(
                    env, otp=otp, signed_duo_txid_token=signed_duo_txid_token)
                self.wf.save_password('prodlogin%s' % env, token)
            except VPNException:
                self.are_you_on_the_vpn()
            except TwoFAException:
                otp = utils.ask_for_input(
                    self.wf, DUO_2FA_MSG, "Two-factor authentication required.")
                if otp:
                    return self.prodlogin(env, otp=otp)
                else:
                    self.duo_push(env)
            except InvalidOTPException:
                return self.prodlogin(env)
            except TokenException:
                self.ldap(clear=True)
                return self.prodlogin(env)

        return token

    def duo_push(self, env):
        (user, password) = self.ldap()
        body = dict(uid=user, password=password)

        result = requests.post(
            BASE_PRODLOGIN_URL % (env, "initiate-two-factor-challenge"),
            json=body,
            headers=self.prodlogin_request_headers()
        )

        if result.status_code != 200 or "signedDuoTxidToken" not in result.json():
            self.wf.logger.error("Failed to initiate Duo Push.")
            sys.exit(1)
        else:
            signed_duo_txid_token = result.json()["signedDuoTxidToken"]
            self.wf.save_password('signed_duo_txid_token%s' %
                                  env, signed_duo_txid_token)
            sys.exit(0)

    def get_signed_duo_txid_token(self, env):
        try:
            signed_duo_txid_token = self.wf.get_password(
                'signed_duo_txid_token%s' % env)
            status = self.get_duo_push_status(env, signed_duo_txid_token)
        except PasswordNotFound:
            status = "DENY"

        if status == "PENDING":
            self.wf.add_item("Waiting for Duo Push to be approved...")
            self.wf.send_feedback()
            sys.exit(0)
        elif status == "DENY":
            try:
                self.wf.delete_password('signed_duo_txid_token%s' % env)
            except PasswordNotFound:
                pass
            return None
        elif status == "ALLOW":
            try:
                self.wf.delete_password('signed_duo_txid_token%s' % env)
            except PasswordNotFound:
                pass
            return signed_duo_txid_token

    def get_duo_push_status(self, env, signed_duo_txid_token):
        (user, password) = self.ldap()

        body = dict(uid=user, password=password,
                    signedDuoTxidToken=signed_duo_txid_token)
        result = requests.post(
            BASE_PRODLOGIN_URL % (env, "check-challenge-status"),
            json=body,
            headers=self.prodlogin_request_headers()
        )

        if result.status_code != 200 or result.json() not in [
            "ALLOW",
            "PENDING",
            "DENY",
        ]:
            self.wf.logger.error("Failed to check 2FA status with Duo.")
            return "DENY"
        else:
            return result.json()

    def generate_prodlogin_token(self, env, otp=None, signed_duo_txid_token=None):
        (user, password) = self.ldap()
        body = dict(uid=user, password=password, otp=otp,
                    signedDuoTxidToken=signed_duo_txid_token)
        result = requests.post(
            BASE_PRODLOGIN_URL % (env, "token"),
            json=body,
            headers=self.prodlogin_request_headers()
        )

        headers = result.headers

        if (
            "akamai" in headers.get("Server", "").lower()
            and "X-Spx-Auth-Supported" in headers
        ):
            raise VPNException

        if result.status_code == 200:
            token = result.json()['token']
            self.wf.save_password('prodlogin%s' % env, token)
            return token
        elif (
            result.status_code == 401
            and "errorType" in result.json()
            and result.json()["errorType"] == "NO_2FA_PROVIDED"
        ):
            raise TwoFAException
        elif otp:
            raise InvalidOTPException
        else:
            raise TokenException

    def prodlogin_request_headers(self):
        return {"X-Origin-RequestId": "alfred-hubspotdev-tools"}

    def prodlogin_headers(self, env, clear=False):
        return {'Authorization': 'Bearer %s' % self.prodlogin(env, clear=clear)}

    def github(self, clear=False):
        return self.user_pass("github", "GitHub (Password or Access Token)", GITHUB_ACCESS_TOKEN_MSG, clear)

    def okta(self, env, clear=False):
        if clear:
            try:
                key = get_okta_keychain_key(env)
                self.wf.delete_password(key)
            except PasswordNotFound:
                pass

        return OktaAuth(self.wf, env)

    def user_pass(self, type_key, type_name, message=None, clear=False):
        if clear:
            del self.wf.settings['user']
            try:
                self.wf.delete_password(type_key)
            except PasswordNotFound:
                pass

        try:
            user = self.wf.settings['user']
        except KeyError:
            user = None

        if not user:
            user = utils.ask_for_input(self.wf, 'Username:', 'Login')
            self.wf.settings['user'] = user

        try:
            password = self.wf.get_password(type_key)
        except PasswordNotFound:
            password = utils.ask_for_input(
                self.wf, message or 'Password for %s:' % type_name, '%s Login' % type_name, password=True)
            self.wf.save_password(type_key, password)

        return (user, password)

    def are_you_on_the_vpn(self):
        self.wf.add_item("Are you on the VPN?")
        self.wf.send_feedback()
        sys.exit(0)
