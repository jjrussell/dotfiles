from tool import Tool
from utils import get_tools_yaml, parse_tools_yaml

TOOLS_HOME_ENTRY = dict(title='@HubSpotDev Tools',
                        description='https://product.hubteam.com', url='https://product.hubteam.com')
TOOLS_EDIT_ENTRY = dict(title=u'\U0001f4dd Add a link', description='Add or edit a link in this list (for all users)',
                        url='https://git.hubteam.com/HubSpot/tools/edit/master/tools.yaml')


class Bookmarks(Tool):
    def __init__(self, wf, auth, args):
        super(Bookmarks, self).__init__(wf, ['title', 'description'])
        self.auth = auth

    def get_from_server(self, url, **kwargs):
        return parse_tools_yaml(super(Bookmarks, self).get_from_server(url, **kwargs))

    def list_all(self):
        return self.wf.cached_data("bookmarks", self._get_and_parse_tools, max_age=600)

    def _get_and_parse_tools(self):
        bookmarks = get_tools_yaml(self)

        bookmarks = filter(lambda bookmark: 'title' in bookmark, bookmarks)

        bookmarks.append(TOOLS_HOME_ENTRY)
        bookmarks.append(TOOLS_EDIT_ENTRY)
        return bookmarks

    def to_item(self, bookmark):
        return dict(title=bookmark['title'],
                    subtitle=bookmark['description'] if 'description' in bookmark else '',
                    arg=bookmark.get('url', None),
                    uid=bookmark.get('url', None),
                    valid=bookmark.get('valid', True))

    def empty_result(self):
        return [self.to_item(TOOLS_HOME_ENTRY)]
