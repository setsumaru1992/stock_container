#! /bin/bash

bundle install
# rails assets:precompile

pidfile="tmp/pids/server.pid"
touch $pidfile
rm $pidfile

port=${STOCK_PORT}
pre_process="$(ps -ef |grep ":$port" |grep -v "grep" |awk '{print $2}')"
kill -9 $pre_process
RAILS_ENV=production
RAILS_ENV=${RAILS_ENV} bundle exec rails s -p $port -b "0.0.0.0" &

logfile="log/${RAILS_ENV}.log"
touch $logfile # 起動時はないため明示的に作成
tail -f $logfile