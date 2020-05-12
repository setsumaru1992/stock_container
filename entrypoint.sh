# https://qiita.com/koara-local/items/1377ddb06796ec8c628a
if   [ -e /etc/debian_version ] ||
     [ -e /etc/debian_release ]; then
    # Check Ubuntu or Debian
    if [ -e /etc/lsb-release ]; then
        # Ubuntu
        distri_name="ubuntu"
    else
        # Debian
        distri_name="debian"
    fi
elif [ -e /etc/redhat-release ]; then
    if [ -e /etc/oracle-release ]; then
        # Oracle Linux
        distri_name="oracle"
    else
        # Red Hat Enterprise Linux
        distri_name="redhat"
    fi
elif [ -e /etc/arch-release ]; then
    # Arch Linux
    distri_name="arch"
else
    # Other
    distri_name="unkown"
fi


if [ "$distri_name" = "ubuntu" ]; then
    cd $(dirname $0 >> /dev/null && pwd)
else
    cd $(dirname $0 && pwd)
fi

CONTAINER_ROOT="$(pwd)"

envpath=$(readlink .env)
source $envpath

kill_process () {
    port=$1
    headerSample="PID"
    pid=$(lsof -i :$port | grep -v $headerSample | head -n 1 | awk '{print $2}')
    if [ ! "$pid" = "" ]; then
        execCmd="kill -9 $pid"
        echo "$execCmd"
        bash -c "$execCmd"
    fi
}

RAILS_ROOT="${CONTAINER_ROOT}/stock_rails"
cd "${RAILS_ROOT}"
kill_process ${STOCK_PORT}
spring stop
rm "tmp/pids/server.pid"

bundle install
rails assets:precompile
rails server -p ${STOCK_PORT} &
