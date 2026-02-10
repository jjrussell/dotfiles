import copy

from tool import Tool
from utils import get_tools_yaml, parse_tools_yaml


class Go(Tool):
    def __init__(self, wf, auth, args):
        super(Go, self).__init__(wf, ['golinks'])
        self.auth = auth
        self.args = args

    def get_from_server(self, url, **kwargs):
        return parse_tools_yaml(super(Go, self).get_from_server(url, **kwargs))

    def list_all(self):
        return self.wf.cached_data("go-links", self._get_and_parse_tools, max_age=600)

    def _get_and_parse_tools(self):
        tools = get_tools_yaml(self)

        golinks = []
        for bookmark in tools:
            if 'golinks' in bookmark:
                for golink in bookmark.get('golinks'):
                    bookmark_golink = copy.copy(bookmark)
                    bookmark_golink['golink'] = golink
                    golinks.append(bookmark_golink)

        return golinks

    def filter(self, results, arguments):
        if arguments and len(arguments) and len(arguments[0].strip()):
            query = arguments[0][1:]
            exact_match = '/' in query
            golink = query.split('/')[0].lower()
            if exact_match:
                return filter(lambda bookmark: bookmark.get('golink').lower() == golink, results)
            else:
                return filter(lambda bookmark: bookmark.get('golink').lower().startswith(query), results)
        return results

    def to_item(self, bookmark):
        golink = bookmark.get('golink')
        link = bookmark.get('url')
        uid = golink
        if 'argurl' in bookmark and self.args and len(self.args) and len(self.args[0].strip()):
            query = self.args[0][1:].split('/')
            if len(query) > 1:
                argurl = bookmark.get('argurl')
                golink, link = handle_argurl(argurl, query, golink)

        return dict(title='go/%s' % golink,
                    subtitle=bookmark.get('title', ''),
                    autocomplete='/%s' % golink,
                    arg=link,
                    uid=uid,
                    valid=True)

    def empty_result(self):
        return []


def handle_argurl(argurl, query, golink):
    if '{0}' in argurl:
        args = query[1:]
        link = handle_new_style(argurl, args)
        golink = '%s/%s' % (golink, '/'.join(args))
    else:
        arg = query[1]  # single arg supported
        link = handle_old_style(argurl, arg)
        golink = '%s/%s' % (golink, arg)
    return golink, link


def handle_new_style(argurl, args):
    """
    Note: replacing one placeholder at the time supposing placeholders can be repeated and can come in any order.
    """
    link = argurl
    i = 0
    for arg in args:
        link = link.replace('{%s}' % i, arg)
        i += 1
    return link


def handle_old_style(argurl, arg):
    link = argurl.split('%s')
    link = arg.join(link)
    return link
