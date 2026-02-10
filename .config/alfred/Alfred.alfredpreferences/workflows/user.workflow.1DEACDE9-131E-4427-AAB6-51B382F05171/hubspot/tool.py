import requests


class Tool(object):
    def __init__(self, wf, search_fields=None, max_age=300, vpn_required=True):
        self.wf = wf
        self.search_fields = search_fields
        self.max_age = max_age
        self.vpn_required = vpn_required

    def list_all(self):
        return []

    def execute(self, args):
        results = self.list_all()
        results = self.filter(results, args)
        if len(results):
            self.add_items(results)
        else:
            for result in self.empty_result():
                self.wf.add_item(**result)

    def get(self, key, url, **kwargs):
        return self.wf.cached_data(key, lambda: self.get_from_server(url, **kwargs), max_age=self.max_age)

    def post(self, key, url, **kwargs):
        return self.wf.cached_data(key, lambda: self.post_to_server(url, **kwargs), max_age=self.max_age)

    def get_from_server(self, url, **kwargs):
        result = requests.get(url, **kwargs)
        result.raise_for_status()
        if self.vpn_required and 'Server' in result.headers and result.headers['Server'] == 'cloudflare' and 'X-HubSpot-Correlation-Id' not in result.headers:
            self.auth.are_you_on_the_vpn()
        return result.json()

    def post_to_server(self, url, **kwargs):
        result = requests.post(url, **kwargs)
        result.raise_for_status()
        return result.json()

    def filter(self, results, args):
        if args and len(args) and len(args[0].strip()):
            query = ' '.join(args).strip()
            if query:
                results = self.wf.filter(
                    query, results, key=self.search_key, min_score=20)
        return results

    def search_key(self, item):
        elements = []
        if not self.search_fields:
            elements.append(item)
        else:
            for field in self.search_fields:
                path = field.split('.')
                child = item
                result = None
                for el in path:
                    if el in child:
                        child = child[el]
                        result = child
                    else:
                        break
                if result:
                    elements.append(result)
        return u' '.join(elements)

    def add_items(self, results):
        for result in results:
            self.wf.add_item(**self.to_item(result))

    def to_item(self, result):
        return result
