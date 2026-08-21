#!/usr/bin/env bash
out="$(mktemp)"
tmux display-popup -E -w 90% -h 90% -d '#{pane_current_path}' -T "do the thing" \
     "revdiff master --cross-file-hunks --untracked -o '$out'"
cat "$out"
rm -f "$out"
