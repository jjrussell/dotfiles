import urllib

from tool import Tool
from utils import fetch

SINGULARITY_API_URL = 'https://private.hubteam%s.com/singularity-iad/api/requests/ids?requestIdLike=%s'
SINGULARITY_URL = 'https://private.hubteam%s.com/singularity/request/%s'
APP_OPTICS_URL = 'https://my.appoptics.com/apm/%s/services/%s'
LOGFETCH_URL = 'https://private.hubteam.com/logfetch/tail/%s/service/%s'


class Singularity(Tool):
    def __init__(self, name, env, url_pattern, icon, wf, auth, args):
        super(Singularity, self).__init__(wf, ['name'])
        self.name = name
        self.env = env
        self.url_pattern = url_pattern
        self.icon = icon
        self.auth = auth

    def list_all(self):
        return [dict(full_name=self.name,
                     language='Start typing a service name',
                     valid=False)]

    def filter(self, results, args):
        def get(clear=False):
            if args and len(args) and len(args[0].strip()):
                search = ' '.join(args)
                search = urllib.quote(search)
                return self.get('singularity%s-%s' % (self.env, search), SINGULARITY_API_URL % (self.env, search), headers=self.auth.prodlogin_headers(self.env, clear=clear))
            else:
                return []

        return fetch(get)

    def to_item(self, task):
        return dict(title=task,
                    arg=self.url_pattern % task,
                    icon='icons/%s.png' % self.icon,
                    uid=task,
                    valid=True)

    def empty_result(self):
        return [dict(title=self.name, subtitle='No services found', valid=False, icon='icons/%s.png' % self.icon)]


class SingularityPROD(Singularity):
    def __init__(self, *args):
        super(SingularityPROD, self).__init__(
            'Singularity', '', SINGULARITY_URL % ('', '%s'), 'singularity', *args)


class SingularityQA(Singularity):
    def __init__(self, *args):
        super(SingularityQA, self).__init__(
            'Singularity QA', 'qa', SINGULARITY_URL % ('qa', '%s'), 'singularity', *args)


class AppOpticsPROD(Singularity):
    def __init__(self, *args):
        super(AppOpticsPROD, self).__init__(
            'AppOptics', '', APP_OPTICS_URL % (134100, '%s'), 'appoptics', *args)


class AppOpticsQA(Singularity):
    def __init__(self, *args):
        super(AppOpticsQA, self).__init__(
            'AppOptics', 'qa', APP_OPTICS_URL % (131525, '%s'), 'appoptics', *args)


class TailPROD(Singularity):
    def __init__(self, *args):
        super(TailPROD, self).__init__('Tail', '',
                                       LOGFETCH_URL % ('%s', 'PROD'), 'logfetch', *args)


class TailQA(Singularity):
    def __init__(self, *args):
        super(TailQA, self).__init__('Tail QA', 'qa',
                                     LOGFETCH_URL % ('%s', 'QA'), 'logfetch', *args)
