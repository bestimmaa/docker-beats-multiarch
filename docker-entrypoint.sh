#!/bin/bash

set -euo pipefail

# Check if the the user has invoked the image with flags.
# eg. "filebeat -c filebeat.yml"
if [[ -z $1 ]] || [[ ${1:0:1} == '-' ]] ; then
  exec /usr/share/filebeat/filebeat "$@"
else
  # They may be looking for a Beat subcommand, like "filebeat setup".    
  subcommands=$(/usr/share/filebeat/filebeat help |
  awk 'BEGIN {RS=""; FS="\n"} /Available Commands:/' |
  awk '/^\s+/ {print $1}')

  # If we _did_ get a subcommand, pass it to filebeat.
  for subcommand in $subcommands; do
      if [[ $1 == $subcommand ]]; then
        exec /usr/share/filebeat/filebeat "$@"
      fi
  done
fi

# If neither of those worked, then they have specified the binary they want, so
# just do exactly as they say.
exec "$@"
