from tool import Tool
from utils import fetch

PACKAGE_LIST_URL = 'https://private.hubteam.com/bender-packages/meta/v1/detailedPackagesList.json'


class Package(Tool):
    """
    Bender package search

    Example:

    > package style_guide       show all packages with name matching 'style_guide'
    > package style_guide@      show all versions of 'style_guide'
    > package style_guide@8     show all versions of 'style_guide' matching 8 (usually one)
    """

    def __init__(self, wf, auth, args):
        super(Package, self).__init__(wf, ['name'])
        self.auth = auth
        self.wf = wf

    def list_all(self):
        return fetch(lambda clear=False: self.get('packages', PACKAGE_LIST_URL, headers=self.auth.prodlogin_headers('', clear=clear), allow_redirects=False)['data'])

    def filter(self, results, args):
        if not args or len(args) == 0:
            return results

        package_string = args[0].strip()
        if '@' in package_string:
            package_name, major_version = package_string.split('@')
            # first filter over package names
            packages = filter(
                lambda package: package['name'] == package_name, results)

            # filter and return matching versions
            results = []
            for package in packages:
                if len(major_version):
                    versions = self.wf.filter(major_version, package['versions'], key=lambda package: str(
                        package['majorVersion']), min_score=20)
                else:
                    versions = package['versions']
                for v in versions:
                    results.append(dict(
                        name=package['name'],
                        single_version=True,
                        version=v
                    ))
            return results
        else:
            return self.wf.filter(package_string, results, key=self.search_key, min_score=20)

    def to_item(self, package):
        if package.get('single_version'):
            combined_version = '{}.{}'.format(
                package['version']['majorVersion'], package['version']['minorVersion'])
            if 'branch' in package['version']:
                subtitle = 'Version: {}\tBranch: {}'.format(
                    combined_version, package['version']['branch'])
            else:
                subtitle = 'Version: {}'.format(combined_version)
            return dict(
                title=package['name'],
                subtitle=subtitle,
                autocomplete='{}@{}'.format(
                    package['name'], package['version']['majorVersion']),
                arg='https://private.hubteam.com/bender-packages/packages/{}/{}'.format(
                    package['name'], package['version']['majorVersion']),
                icon='icons/bender.png',
                uid=package['name'],
                valid=True
            )
        else:
            versions_list = ', '.join(['{}.{}'.format(v['majorVersion'], v['minorVersion'] or 0)
                                       for v in package['versions']])
            return dict(
                title=package['name'],
                autocomplete=package['name'] + '@',
                subtitle='Versions: {}'.format(versions_list),
                arg='https://private.hubteam.com/bender-packages/packages/{}'.format(
                    package['name']),
                icon='icons/bender.png',
                uid=package['name'],
                valid=True
            )

    def empty_result(self):
        return [dict(title='No Results', subtitle='No packages found', valid=False, icon='icons/bender.png')]
