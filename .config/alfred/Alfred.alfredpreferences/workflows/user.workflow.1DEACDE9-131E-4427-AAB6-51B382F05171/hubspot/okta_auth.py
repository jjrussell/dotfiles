import base64
import hashlib
import os
import webbrowser

import requests
from requests.auth import AuthBase
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
from urllib import urlencode
from urlparse import urlparse, parse_qs

from workflow import PasswordNotFound

OKTA_BASE_URL = "https://hubspot.okta.com"
CLIENT_ID = "OTUgL6XRjQfJFY637Zwu"
PORT = 36583
REDIRECT_URI = "http://localhost:{}".format(PORT)
KEYCHAIN_USERNAME = "requests-okta"

CORP_BASE_URL = 'https://api.hubapi%s.com'


def get_okta_keychain_key(env):
    if env == 'qa':
        return 'okta-qa'
    else:
        return 'okta-prod'


class OktaAuth(AuthBase):
    def __init__(self, wf, env):
        self.wf = wf
        self.env = env

    def __call__(self, r):
        try:
            auth_cookie = self.wf.get_password(get_okta_keychain_key(self.env))
        except PasswordNotFound:
            auth_cookie = get_auth_cookie(self.wf, self.env)
        csrf = base64.urlsafe_b64encode(
            os.urandom(16)).rstrip(b"=").decode("ascii")
        cookies = {"internal-auth": auth_cookie, "internal-csrf": csrf}
        r.prepare_cookies(cookies)
        r.headers["X-Tools-CSRF"] = csrf
        r.register_hook("response", self.handle_response)
        return r

    def handle_response(self, r, **kwargs):
        if r.status_code == requests.codes.unauthorized:
            self.wf.save_password(get_okta_keychain_key(self.env), "")
            return

        auth_cookie = r.cookies.get("internal-auth")
        if auth_cookie:
            self.wf.save_password(
                get_okta_keychain_key(self.env), auth_cookie)
            return


class OAuthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        o = urlparse(self.path)
        qs = parse_qs(o.query)

        if qs["state"][0] != self.server.state:
            self.send_error(400, "Invalid state")
            print("Invalid state")
            return

        if "error_description" in qs:
            self.send_error(400, qs["error_description"][0])
            print(qs["error_description"][0])
            return

        self.server.code = qs["code"][0]

        self.send_response(200)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.end_headers()
        self.wfile.write(
            "Okta Login for Alfred successful, close window and try your Alfred request again.".encode("utf-8"))

    def log_message(self, format, *args):
        pass


def get_authorization_code(code_verifier, wf):
    state = base64.urlsafe_b64encode(
        os.urandom(32)).rstrip(b"=").decode("ascii")
    code_challenge = (
        base64.urlsafe_b64encode(hashlib.sha256(
            code_verifier.encode("ascii")).digest())
        .rstrip(b"=")
        .decode("ascii")
    )

    query = {
        "response_type": "code",
        "client_id": CLIENT_ID,
        "redirect_uri": REDIRECT_URI,
        "scope": "openid email profile groups",
        "state": state,
        "code_challenge": code_challenge,
        "code_challenge_method": "S256",
    }

    webbrowser.open(OKTA_BASE_URL + "/oauth2/v1/authorize?" + urlencode(query))

    server = HTTPServer(("localhost", PORT), OAuthHandler)

    server.code = None
    server.state = state
    server.handle_request()

    return server.code


def get_id_token(wf):
    code_verifier = (
        base64.urlsafe_b64encode(os.urandom(32)).rstrip(b"=").decode("ascii")
    )
    authorization_code = get_authorization_code(code_verifier, wf)
    payload = {
        "grant_type": "authorization_code",
        "code": authorization_code,
        "redirect_uri": REDIRECT_URI,
        "code_verifier": code_verifier,
        "client_id": CLIENT_ID,
    }
    r = requests.post(OKTA_BASE_URL + "/oauth2/v1/token", data=payload)

    id_token = r.json()["id_token"]
    return id_token


def get_auth_cookie(wf, env):
    id_token = get_id_token(wf)

    payload = {"token": id_token}
    r = requests.post(
        CORP_BASE_URL % env + "/internal-login/v1/login/okta", json=payload)
    r.raise_for_status()

    auth_cookie = r.cookies["internal-auth"]
    wf.save_password(get_okta_keychain_key(env), auth_cookie)
    return auth_cookie
