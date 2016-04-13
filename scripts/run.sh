set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_PATH=${CONFIG_PATH:-"$DIR/config/config.json"}
echo "Running with config $CONFIG_PATH"

mongo-connector -c "$CONFIG_PATH" --stdout
