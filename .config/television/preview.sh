#!/bin/bash

file="$1"
mime=$(file --brief --mime-type "$file")

case "$mime" in
  image/*)
      # kitty icat "$file"
      ;;
  application/pdf)
      pdftotext "$file" - | head -200
      ;;
  application/zip|application/gzip|application/x-tar|application/x-bzip2|application/x-xz)
      tar tf "$file" 2>/dev/null || unzip -l "$file" 2>/dev/null
      ;;
  *)
      bat -n --color=always "$file"
      ;;
esac
