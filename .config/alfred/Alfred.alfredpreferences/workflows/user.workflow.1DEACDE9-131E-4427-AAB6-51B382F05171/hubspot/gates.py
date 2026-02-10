import urllib

from tool import Tool
from utils import fetch

GATES_API_URL = "https://api.hubapi%s.com/gating/v1/gating-manager/metadata"
GATE_URL = "https://tools.hubteam%s.com/gates/gates/%s/hubs"


class Gates(Tool):
    def __init__(self, env, cache_key, wf, auth, args):
        super(Gates, self).__init__(wf, ['name'])
        self.env = env
        self.cache_key = cache_key
        self.auth = auth

    def get_all_gates(self, clear=False):
        return self.get(self.cache_key, GATES_API_URL % self.env, auth=self.auth.okta(self.env, clear))

    def list_all(self):
        return fetch(self.get_all_gates)

    def to_item(self, gate):
        return dict(title=gate.get('name'),
                    arg=GATE_URL % (self.env, urllib.quote(gate.get('name'))),
                    uid=gate.get('name'),
                    valid=True)

    def empty_result(self):
        return [dict(title='Gates' + (' (QA)' if self.env == 'qa' else ''),
                     subtitle='No gates found with that name',
                     valid=False)]


class GatesPROD(Gates):
    def __init__(self, *args):
        super(GatesPROD, self).__init__('', 'gates-prod', *args)


class GatesQA(Gates):
    def __init__(self, *args):
        super(GatesQA, self).__init__('qa', 'gates-qa', *args)
