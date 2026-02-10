from tool import Tool
from utils import fetch

BLAZAR_URL = 'https://bootstrap.hubteam.com/blazar/v2/branches/state?property=gitInfo.id&property=gitInfo.host&property=gitInfo.organization&property=gitInfo.repository&property=gitInfo.branch&property=gitInfo.active&property=lastBuild.state&property=pendingBuild.state'
STATUS_ICONS = dict(
    SUCCEEDED='-success',
    FAILED='-error',
    UNSTABLE='-error',
    CANCELLED='-error',
    SKIPPED='-error',
    QUEUED='-building',
    LAUNCHING='-building',
    IN_PROGRESS='-building',
    DISCOVERING_MODULES='-building',
)


def get_repo_title(build):
    git_info = build.get('gitInfo')
    host = git_info.get('host')
    org = git_info.get('organization')
    repo_name = git_info.get('repository')
    if host != 'git.hubteam.com':
        return "%s/%s/%s" % (host, org, repo_name)
    else:
        return "%s/%s" % (org, repo_name)


class Blazar(Tool):
    def __init__(self, wf, auth, args):
        super(Blazar, self).__init__(wf, ['gitInfo.repository'], 30)
        self.auth = auth
        self.args = args

    def list_all(self):
        def get(clear=False):
            branches = self.get('blazar-builds', BLAZAR_URL,
                                headers=self.auth.prodlogin_headers('', clear=clear))
            return filter(lambda branch: branch.get('gitInfo').get('active'), branches)

        return fetch(get)

    def filter(self, results, arguments):
        if arguments and len(arguments) > 1 and len(arguments[0].strip()):
            org_and_repo = arguments[0].strip()
            filtered = self.wf.filter(
                org_and_repo, results, key=lambda build: get_repo_title(build))
            branch = arguments[1].strip()
            if len(branch):
                filtered = self.wf.filter(branch, filtered, key=lambda build: build.get(
                    'gitInfo').get('branch'), min_score=20)
            return filtered
        else:
            return super(Blazar, self).filter(results, arguments)

    def to_item(self, repo):
        git_info = repo.get('gitInfo')
        host = git_info.get('host')
        org = git_info.get('organization')
        repo_name = git_info.get('repository')
        branch = git_info.get('branch')
        branch_id = git_info.get('id')
        title = get_repo_title(repo)
        if 'pendingBuild' in repo:
            state = repo.get('pendingBuild').get('state')
        elif 'lastBuild' in repo:
            state = repo.get('lastBuild').get('state')
        else:
            state = 'IN_PROGRESS'
        if self.args and len(self.args) > 1 and len(self.args[0].strip()):
            autocomplete = title + ' ' + branch
        else:
            autocomplete = title + ' '
        if state in STATUS_ICONS:
            icon = 'icons/build%s.png' % STATUS_ICONS[state]
        else:
            icon = 'icons/build.png'
        return dict(title=title,
                    subtitle=git_info.get('branch'),
                    arg='https://private.hubteam.com/blazar/branches/%d' % branch_id,
                    icon=icon,
                    uid='%s/%s/%s/%s' % (host, org, repo_name, branch),
                    autocomplete=autocomplete,
                    valid=True)

    def empty_result(self):
        return [dict(title='Repository', subtitle='No repos found', valid=False, icon='icons/build.png')]
