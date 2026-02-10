import urllib

from tool import Tool
from utils import fetch

SERVICES_URL = 'https://api.hubapi%s.com/api-catalog/v0/services'
API_CATALOG_URL = 'https://tools.hubteam%s.com/api-catalog/services/%s/%s/spec/internal'
GOGGLES_URL = 'https://tools.hubteam%s.com/api/%s/%s?showRequestDetails=true'


def hasArgs(args):
    return args and len(args) and len(args[0].strip())


def construct_tree(paths):
    tree = dict(children=dict(), methods=dict())
    for path, data in paths.iteritems():
        parts = path.split('/')[1:]
        current = tree
        for i, part in enumerate(parts):
            if part not in current.get('children'):
                current.get('children')[part] = dict(
                    children=dict(),
                    methods=dict())
            current = current.get('children')[part]
            if i == len(parts) - 1:
                for method, method_data in data.iteritems():
                    current.get('methods')[method] = dict(
                        parameters=method_data.get('parameters'),
                        tags=method_data.get('tags'),
                        operation_id=method_data.get('operationId'))
    return tree


def filter_tree(tree, path_parts):
    base_path = ''

    while len(path_parts) > 0:
        part = path_parts.pop(0)
        if len(path_parts) > 0:
            tree = tree.get('children').get(part)
            base_path = base_path + '/' + part
        else:
            part_and_method = part.split(' ')
            if len(part_and_method) > 1:
                tree = tree.get('children').get(part_and_method[0])
                base_path = base_path + '/' + part_and_method[0]
                tree['children'] = dict()
                tree['methods'] = {k: v for k, v in tree.get('methods').items()
                                   if k.startswith(part_and_method[1].lower())}
            else:
                tree['children'] = {k: v for k, v in tree.get('children').items()
                                    if k.startswith(part_and_method[0])}

    return (base_path, tree)


class ApiCatalog(Tool):
    def __init__(self, env, cache_key_prefix, wf, auth, args):
        super(ApiCatalog, self).__init__(wf, ['apicatalog'])
        self.env = env
        self.cache_key_prefix = cache_key_prefix
        self.auth = auth
        self.args = args

    def fetch_all(self, clear=False):
        return self.get('apicatalog',
                        SERVICES_URL % self.env,
                        auth=self.auth.okta(self.env, clear))

    def list_all(self):
        if not hasArgs(self.args):
            result = fetch(self.fetch_all)
            return map(lambda service: self.to_service(service), result.get('results'))
        else:
            return []

    def search_services(self, search):
        def do_search(clear=False):
            escaped_search = urllib.quote(search)
            return self.get('apicatalog-%s' % search,
                            SERVICES_URL % self.env + '?q=' + escaped_search,
                            auth=self.auth.okta(self.env, clear))
        return do_search

    def get_service(self, deploy_config, version):
        def do_get(clear=False):
            return self.get('apicatalog-%s-%s' % (deploy_config, version),
                            SERVICES_URL % self.env + '/' + deploy_config + '/' + version + '/specs/internal',
                            auth=self.auth.okta(self.env, clear))
        return do_get

    def filter(self, results, args):
        if hasArgs(args):
            search = ' '.join(args)
            parts = search.split('/')
            if len(parts) == 1 or len(parts) < 3:
                result = fetch(self.search_services(parts[0]))
                return map(lambda service: self.to_service(service), result.get('results'))
            else:
                result = fetch(self.get_service(parts[0], parts[1]))
                paths = result.get('paths')
                tree = construct_tree(paths)
                self.wf.cached_data(
                    '%s-%s' % (parts[0], parts[1]), lambda: construct_tree(paths), max_age=self.max_age)
                version = result.get('info').get('version')
                if version in tree.get('children'):
                    tree = tree.get('children').get(version)
                    result['basePath'] = result['basePath'] + '/' + version
                path_parts = parts[2:]
                return self.tree_to_items(result, *filter_tree(tree, path_parts))
        else:
            return results

    def to_service(self, service):
        return self.wf.add_item(service.get('deployConfig') + '/' + service.get('version'),
                                subtitle='Tab to explore or hit enter to go to spec for ' +
                                service.get('appRoot'),
                                arg=API_CATALOG_URL % (self.env, service.get(
                                    'deployConfig'), service.get('version')),
                                autocomplete=service.get(
            'deployConfig') + '/' + service.get('version') + '/',
            icon='icons/api.png',
            uid=service.get('id'),
            valid=True)

    def tree_to_items(self, service, base_path, tree):
        title = service.get('info').get('title')
        version = service.get('info').get('version')
        api_base_path = service.get('basePath')

        items = []
        for method, method_data in tree.get('methods').iteritems():
            anchor = '%s-%s' % (method_data.get('tags')
                                [0], method_data.get('operation_id'))
            item = self.wf.add_item(title + '/' + version + base_path + ' ' + method.upper(),
                                    subtitle='Hit enter to go to spec for ' +
                                    api_base_path + base_path + ' ' + method.upper(),
                                    arg=API_CATALOG_URL % (
                self.env, title, version) + '#operations-%s' % anchor,
                autocomplete=title + '/' + version + base_path + ' ' + method.upper(),
                icon='icons/api.png',
                uid=method_data.get('operation_id'),
                valid=True)

            item.add_modifier('cmd', icon='icons/goggles.png', subtitle='Hit enter to open goggles for ' + api_base_path +
                              base_path + ' ' + method.upper(), arg=self.goggles_url(service, api_base_path + base_path, method, method_data))

            items.append(item)

        for child in tree.get('children').keys():
            items.append(self.wf.add_item(title + '/' + version + base_path + '/' + child,
                                          subtitle='Tab to explore ' + api_base_path + base_path + '/' + child,
                                          autocomplete=title + '/' + version + base_path + '/' + child + '/',
                                          uid='parent-' + title + '/' + version + base_path + '/' + child,
                                          icon='icons/api.png',
                                          valid=False))
        return items

    def goggles_url(self, service, path, method, method_data):
        api_url = service.get('host') + path
        api_url = api_url.replace('{', '((').replace('}', '))')
        for param in method_data.get('parameters'):
            if param.get('required') and param.get('in') == 'query':
                if '?' in api_url:
                    api_url += '&'
                else:
                    api_url += '?'
                api_url += param.get('name') + '=' + \
                    '((%s))' % param.get('name')

        return GOGGLES_URL % (
            self.env, method, urllib.quote_plus(api_url))

    def add_items(self, results):
        pass

    def empty_result(self):
        return [dict(title='API Catalog', subtitle='No services found', valid=False, icon='icons/api.png')]


class ApiCatalogPROD(ApiCatalog):
    def __init__(self, *args):
        super(ApiCatalogPROD, self).__init__('', 'apicatalog-prod', *args)


class ApiCatalogQA(ApiCatalog):
    def __init__(self, *args):
        super(ApiCatalogQA, self).__init__('qa', 'apicatalog-qa', *args)
