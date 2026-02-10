import os
import sys
import traceback

from workflow import Workflow3


def main(wf):
    from hubspot import Auth, utils, TOOLS

    (args, tool) = utils.parse_args(wf.args)
    Tool = TOOLS[tool]
    auth = Auth(wf)
    tool = Tool(wf, auth, args)

    if wf.update_available:
        wf.add_item('New version available',
                    'Hit enter to download update',
                    autocomplete='workflow:update',
                    icon='icons/download.png')
        wf.send_feedback()
        sys.exit(0)

    tool.execute(args)
    wf.send_feedback()
    return 0


if __name__ == '__main__':
    wf = Workflow3(libraries=[os.getcwd() + '/lib'],
                   update_settings={'github_slug': 'HubSpot/alfred-hubspotdev-tools'})

    try:
        sys.exit(wf.run(main))
    except Exception, e:
        wf.logger.error(traceback.format_exc())
        raise e
