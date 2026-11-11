#!/bin/zsh
# Update an older install: removes the old version, then installs this one. Usage: ./scripts/update.sh <unzipped original mod folder> [options]
HERE="${0:A:h:h}"
"$HERE/scripts/uninstall.sh" || exit 1
"$HERE/scripts/install.sh" "$@"
