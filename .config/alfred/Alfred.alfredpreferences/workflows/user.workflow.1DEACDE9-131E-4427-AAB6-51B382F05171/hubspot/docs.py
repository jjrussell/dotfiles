from tool import Tool

ALGOLIA_APPLICATION_ID = '99Q9UZW2Q8'
ALGOLIA_API_KEY = 'a972db581c2410a1f8276eab3819a936'

URL = 'https://%s-dsn.algolia.net/1/indexes/*/queries' % ALGOLIA_APPLICATION_ID.lower()
PARAMS = {
    'x-algolia-application-id': ALGOLIA_APPLICATION_ID,
    'x-algolia-api-key': ALGOLIA_API_KEY
}
class Docs(Tool):
    def __init__(self, wf, auth, args):
        super(Docs, self).__init__(wf)
        self.auth = auth
        self.args = args

    def filter(self, results, args):
        if args and len(args) and len(args[0].strip()):
            search = ' '.join(args)
            data = '{"requests":[{"indexName":"hs-docs-test","params":"query=' + search + '&hitsPerPage=20&facetFilters=%5B%22tags%3A-hidden%22%5D"}]}'
            result = self.post('algolia-docs-%s' % search, URL, params=PARAMS, data=data)
            return result.get('results')[0].get('hits')
        else:
            return []

    def to_item(self, result):
        hierarchy = result.get('hierarchy')

        for lvl in range(0, 6):
            lvl_name = hierarchy.get('lvl%s' % lvl)
            if lvl_name:
                if lvl is 0:
                    title = lvl_name
                else:
                    title += ' > ' + lvl_name

        return dict(title=title,
                    subtitle=result.get('content'),
                    arg=result.get('url'),
                    uid=result.get('objectID'),
                    valid=True)

    def empty_result(self):
        if self.args and len(self.args):
            return [dict(title='Doc Search',
                         subtitle='Search HubSpot Product Team Documentation',
                         valid=False)]
        else:
            return [dict(title='Doc Search',
                         subtitle='No docs matched your search',
                         valid=False)]
