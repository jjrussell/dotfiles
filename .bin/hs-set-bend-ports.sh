PORT=$(curl -s https://local.hubspotqa.com/bender-proxy/config | grep -o 'localhost:[0-9]*/automation-ui-canvas/static' | grep -v 'localhost:3333' | tail -1 | cut -d: -f2 | cut -d/ -f1)
bender-proxy set-var canvasStatic "http://localhost:$PORT"
bender-proxy load-custom fe.vee
