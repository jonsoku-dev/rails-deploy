#!/bin/sh
set -e
rm -f /app/tmp/pids/server.pid
bundle exec rake db:create
bundle exec rake db:migrate
# bundle exec rails db:seed
exec "$@"