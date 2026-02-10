import re
import urllib

from tool import Tool
from utils import fetch

JIRA_URL_BASE = 'https://issues.hubspotcentral.com'
JIRA_API_URL = JIRA_URL_BASE + \
    '/rest/api/2/search?jql=%s&fields=id,issuetype,assignee,key,status,summary&maxResults=1'
JIRA_BROWSE_URL = JIRA_URL_BASE + '/browse/%s'

STATUS_ICONS = dict(
    blue=u"\U0001f535",
    yellow=u"\U0001f315",
    green=u"\U00002705",
    grey=u"\U000026aa"
)


class Jira(Tool):
    def __init__(self, wf, auth, args):
        super(Jira, self).__init__(wf, vpn_required=False)
        self.wf = wf
        self.auth = auth

    def list_all(self):
        return [dict(full_name='JIRA', language='Start typing a ticket key', valid=False)]

    def filter(self, results, args):
        if args and len(args) and len(args[0].strip()):
            search_key = args[0].strip()

            # Make sure key matches standard format, e.g. CG-6005
            if re.search(r'^[A-Za-z]+\-\d+$', search_key):
                search_key = urllib.quote('key=%s' % search_key)

                def get(clear=False):
                    result = self.get('jira-%s' % search_key, JIRA_API_URL %
                                      search_key, auth=self.auth.corp(clear=clear))
                    return result.get('issues')

                return fetch(get)
            else:
                return []
        else:
            return []

    def to_item(self, issue):
        return dict(
            title=self.item_title(issue),
            subtitle=self.item_subtitle(issue),
            arg=self.item_url(issue),
            uid='%s-%s' % (issue.get('key'), issue.get('id')),
            icon='icons/jira.png',
            valid=True)

    def item_title(self, issue):
        return '%s: %s' % (issue.get('key'), issue.get('fields').get('summary'))

    def item_subtitle(self, issue):
        fields = issue.get('fields')
        issue_type = fields.get('issuetype')
        assignee = fields.get('assignee', None)
        status = fields.get('status')
        status_color = status.get('statusCategory').get('colorName')

        if status_color == 'medium-gray':
            status_color = 'grey'
        elif status_color == 'blue-gray':
            status_color = 'blue'

        status_icon = STATUS_ICONS.get(status_color, None)
        subtitle = 'Status: %s, Type: %s' % (
            status.get('name'), issue_type.get('name'))

        if assignee:
            subtitle += ', Assignee: %s' % assignee.get('displayName')

        if status_icon:
            subtitle = '%s %s' % (status_icon, subtitle)

        return subtitle

    def item_url(self, issue):
        return JIRA_BROWSE_URL % issue.get('key')

    def empty_result(self):
        return [dict(title='JIRA', subtitle='No tickets found', valid=False, icon='icons/jira.png')]
