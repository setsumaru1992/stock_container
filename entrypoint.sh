cd $(dirname $0 && pwd)
CONTAINER_ROOT="$(pwd)"

envpath=$(readlink .env)
source $envpath

kill_process () {
    port=$1
    headerSample="PID"
    pid=$(lsof -i :$port | grep -v $headerSample | head -n 1 | awk '{print $2}')
    execCmd="kill -9 $pid"
    echo "$execCmd"
    bash -c "$execCmd"
}

RAILS_ROOT="${CONTAINER_ROOT}/stock_rails"
cd "${RAILS_ROOT}"
bundle install
kill_process ${STOCK_PORT}
rails server -p ${STOCK_PORT} &