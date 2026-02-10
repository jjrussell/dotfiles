from tool import Tool
from utils import fetch

DEPLOYER_URL = 'https://bootstrap.hubteam.com/orion/v3/deploy-config-entries/-/names'


class Deployables(Tool):
    def __init__(self, name, url_format, wf, auth, args):
        super(Deployables, self).__init__(wf)
        self.name = name
        self.url_format = url_format
        self.auth = auth

    def list_all(self):
        def get(clear=False):
            return self.get('deployables', DEPLOYER_URL, headers=self.auth.prodlogin_headers('', clear=clear), allow_redirects=False)

        return fetch(get)

    def to_item(self, project):
        return dict(title='%s %s' % (self.name.capitalize(), project),
                    arg='https://private.hubteam.com/' + self.url_format % project,
                    icon='icons/%s.png' % self.name,
                    uid='%s-%s' % (self.name, project),
                    valid=True)

    def empty_result(self):
        return [dict(title=self.name.capitalize(), subtitle='No projects found', valid=False, icon='icons/deployer.png')]


class Deploy(Deployables):
    def __init__(self, *args):
        super(Deploy, self).__init__('deploy', 'orion/deploy/%s', *args)


class Deploys(Deployables):
    def __init__(self, *args):
        super(Deploys, self).__init__(
            'deploys', 'orion/deploys?deployConfigName=%s', *args)


class Tests(Deployables):
    def __init__(self, *args):
        super(Tests, self).__init__('tests', 'acceptance-tests-dashboard/tested-config/%s', *args)
