#!/bin/bash
set -euo pipefail

# You can use following Arguments or combinations of them:
#   --tail 500 - last 500 lines of logs for each container
#   --since 1h - all logs since 1 hour
#   --until 5m - Show logs before a timestamp or relative (e.g. 42m for 42 minutes)
# Please refer to https://docs.docker.com/reference/cli/docker/container/logs/#options

# Default arguments
default_args=(--tail 500)

if [ "$#" -eq 0 ]; then
    args=("${default_args[@]}")
else
    args=("$@")
fi

echo "We will collect logs now with following arguments: ${args[@]}"

docker ps --format '{{.Names}}' |
while IFS= read -r container; do
    docker logs "${args[@]}" --timestamps "$container" 2>&1 |
    sed "s/^/[$container] /"
done | curl https://pastebin.hin-infra.ch/ --data-binary @-

echo -e "\nPlease provide this URL to support, all logs are saved here."

exit 0