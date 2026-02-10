from tool import Tool
from utils import fetch

JANUS_GROUPS_URL = 'https://private.hubteam.com/janus/v1/groups'


class MonitorTeams(Tool):
    def __init__(self, wf, auth, args):
        super(MonitorTeams, self).__init__(wf, ['cn', 'displayName'])
        self.auth = auth

    def list_all(self):
        def get(clear=False):
            all_groups = self.get(
                'janus-groups', JANUS_GROUPS_URL, headers=self.auth.prodlogin_headers('', clear=clear))
            return filter(lambda group: group.get('cn').startswith('hs-'), all_groups)

        return fetch(get)

    def to_item(self, group):
        return dict(title='Monitoring for %s' % (group.get('displayName') or group.get('cn')),
                    subtitle=group.get('cn'),
                    arg='https://private.hubteam.com/monitoring/' +
                        group.get('cn') + '?source=ALFRED',
                    icon='icons/kepler.png',
                    uid=group.get('cn'),
                    valid=True)

    def empty_result(self):
        return [dict(title='Monitoring for team', subtitle='No teams found', valid=False, icon='icons/kepler.png')]
