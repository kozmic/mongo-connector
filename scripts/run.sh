#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"e
CONFIG_PATH=${CONFIG_PATH:-"$DIR/config/config.json"}
WAIT_FOR_PRIMARY=${WAIT_FOR_PRIMARY:-"disabled"}
MONGO_SERVER=$(jq -r .mainAddress ${CONFIG_PATH})
MONGO_SERVER_HOST=$(echo ${MONGO_SERVER}|cut -d':' -f1)
MONGO_SERVER_PORT=$(echo ${MONGO_SERVER}|cut -d':' -f2)

echo "Running with config ${CONFIG_PATH}. WAIT_FOR_PRIMARY=${WAIT_FOR_PRIMARY}"

function wait_for_port {
  echo ">>>>>>>>>>> waiting for mongodb on $1:$2"
  while :
  do
    (echo > /dev/tcp/$1/$2) >/dev/null 2>&1
    result=$?

    if [[ $result -eq 0 ]]; then
        echo "<<<<< $1:$2 is available"
        sleep 1
        break
    fi
    sleep 1
  done
}

if [ "$WAIT_FOR_PRIMARY" = "enabled" ]; then
  echo "Wait for primary on ${MONGO_SERVER} to be enabled..."
  wait_for_port ${MONGO_SERVER_HOST} ${MONGO_SERVER_PORT}
  sleep 1
  mongo ${MONGO_SERVER_HOST}:${MONGO_SERVER_PORT} --eval '
      while (rs.status().startupStatus || (rs.status().hasOwnProperty("myState") && rs.status().myState != 1)) {
         print("Replication not enabled yet...");
         sleep(500);
      };
      print("Success! Replication enabled, starting mongo-connector...");
      '
else
  echo "Wait for primary on ${MONGO_SERVER} is disabled. Starting mongo-connector..."
fi

mongo-connector -c "$CONFIG_PATH" --stdout
