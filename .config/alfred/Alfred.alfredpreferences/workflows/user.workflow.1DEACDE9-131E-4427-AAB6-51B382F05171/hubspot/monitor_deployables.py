from tool import Tool
from utils import fetch

LIVE_DEPLOYABLES_URL = 'https://bootstrap.hubteam.com/live-deployables/v1/deployables?property=name&property=team'


class MonitorDeployables(Tool):
    def __init__(self, env, wf, auth, args):
        super(MonitorDeployables, self).__init__(wf, ['name'])
        self.env = env
        self.auth = auth

    def list_all(self):
        return fetch(lambda clear=False: self.get(
            'live-deployables', LIVE_DEPLOYABLES_URL, headers=self.auth.prodlogin_headers('', clear=clear)))

    def to_item(self, deployable):
        return dict(title='Monitoring for %s' % deployable.get('name'),
                    subtitle=deployable.get('team'),
                    arg='https://private.hubteam.com/monitoring/%s/alerting/deployables/%s/metrics/%s?source=ALFRED' % (
                        deployable.get('team'), deployable.get('name'), self.env),
                    icon='icons/kepler.png',
                    uid=deployable.get('name'),
                    valid=True)

    def empty_result(self):
        return [dict(title='Monitoring for deployable', subtitle='No deployables found', valid=False, icon='icons/kepler.png')]


class MonitorDeployablesPROD(MonitorDeployables):
    def __init__(self, *args):
        super(MonitorDeployablesPROD, self).__init__('prod', *args)


class MonitorDeployablesQA(MonitorDeployables):
    def __init__(self, *args):
        super(MonitorDeployablesQA, self).__init__('qa', *args)
