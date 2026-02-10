import urllib

from tool import Tool
from utils import fetch

GITHUB_URL = 'https://git.hubteam.com/api/v3/search/repositories?q=%s'
DEFAULT_ORGS = ['HubSpot', 'HubSpotProtected']


class GitHub(Tool):
    def __init__(self, wf, auth, args):
        super(GitHub, self).__init__(wf, ['name'])
        self.auth = auth

    def list_all(self):
        return [dict(full_name='Repository',
                     language='Start typing a project name',
                     valid=False)]

    def filter(self, results, args):
        if args and len(args) and len(args[0].strip()):
            if "/" in args[0]:
                [org, repo] = args[0].split("/")
                orgs = [org]
                args[0] = repo
            else:
                orgs = DEFAULT_ORGS
            search = ' '.join(args + map(lambda o: 'org:' + o, orgs))
            search = urllib.quote(search)

            def get(clear=False):
                result = self.get('github-%s' % search, GITHUB_URL %
                                  search, auth=self.auth.github(clear=clear))
                return result['items']
            return fetch(get)
        else:
            return []

    def to_item(self, repo):
        return dict(title=repo.get('full_name'),
                    subtitle=repo.get('language'),
                    arg=repo.get('html_url'),
                    icon='icons/github.png',
                    uid=repo.get('full_name'),
                    valid=True)

    def empty_result(self):
        return [dict(title='Repository', subtitle='No repos found', valid=False, icon='icons/github.png')]
