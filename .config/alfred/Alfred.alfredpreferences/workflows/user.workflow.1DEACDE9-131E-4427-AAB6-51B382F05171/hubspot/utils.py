import subprocess
import sys
import base64

from requests import HTTPError
from yaml import load

TOOLS_YAML_URL = 'https://git.hubteam.com/api/v3/repos/HubSpot/tools/contents/tools.yaml'


def parse_args(args):
    if len(args) == 2:
        return (map(lambda x: x.strip(), args[1].split(' ')), args[0][1:])
    return ([], 'bookmarks')


def with_attributes(obj, attrs):
    for key in attrs:
        obj[key] = attrs[key]
    return obj


def ask_for_input(wf, title, message, password=False):
    alfred_version = wf.alfred_env['version']

    if alfred_version.startswith('4'):
        alfred_application_name = "Alfred 4"
    elif alfred_version.startswith('3'):
        alfred_application_name = "Alfred 3"
    elif alfred_version.startswith('2'):
        alfred_application_name = "Alfred 2"
    else:
        alfred_application_name = "Alfred 5"

    hidden = " with hidden answer" if password else ""
    args = (alfred_application_name, title, message, hidden)
    cmd = """osascript<<END
    tell application "%s"
    activate
    display dialog "%s" with title "%s" buttons {"OK", "Cancel"} default button "OK" cancel button "Cancel" default answer ""%s
    set answer to text returned of result
end tell
return answer
END""" % (args)
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE,
                         stderr=subprocess.STDOUT, shell=True)
    out, err = p.communicate()
    print p.returncode
    if p.returncode == 1:
        sys.exit(0)
    return out.rstrip()


def fetch(get):
    try:
        return get()
    except HTTPError:
        return get(clear=True)


def get_tools_yaml(tool):
    return fetch(lambda clear=False: tool.get(
        'tools-yaml', TOOLS_YAML_URL, auth=tool.auth.github(clear=clear)))


def parse_tools_yaml(result):
    return load(base64.b64decode(result['content']))
