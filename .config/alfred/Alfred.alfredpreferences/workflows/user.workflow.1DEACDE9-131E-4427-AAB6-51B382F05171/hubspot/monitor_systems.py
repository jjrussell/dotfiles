import urllib

from tool import Tool
from utils import fetch

SYSTEMS_URL = 'https://private.hubteam.com/kepler/v1/systems?query=%s'


class MonitorSystems(Tool):
    def __init__(self, env, wf, auth, args):
        super(MonitorSystems, self).__init__(wf, ['name'])
        self.env = env
        self.auth = auth

    def list_all(self):
        return [dict(systemName='system',
                     team='Start typing a system name',
                     valid=False)]

    def filter(self, results, args):
        if args and len(args) and len(args[0].strip()):
            search = ' '.join(args)
            search = urllib.quote(search)
            return fetch(lambda clear=False: self.get('systems-%s' % search, SYSTEMS_URL %
                                                      search, headers=self.auth.prodlogin_headers('', clear=clear)))
        else:
            return []

    def to_item(self, system):
        return dict(title='Monitoring for %s' % system.get('systemName'),
                    subtitle=system.get('team'),
                    arg='https://private.hubteam.com/monitoring/%s/alerting/systems/%s?environment=%s&source=ALFRED' % (
                        system.get('team'), system.get('systemId'), self.env),
                    icon='icons/kepler.png',
                    uid=str(system.get('systemId')),
                    valid=True)

    def empty_result(self):
        return [dict(title='Monitoring for system', subtitle='No systems found', valid=False, icon='icons/kepler.png')]


class MonitorSystemsPROD(MonitorSystems):
    def __init__(self, *args):
        super(MonitorSystemsPROD, self).__init__('prod', *args)


class MonitorSystemsQA(MonitorSystems):
    def __init__(self, *args):
        super(MonitorSystemsQA, self).__init__('qa', *args)
