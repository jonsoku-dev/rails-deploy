#!/bin/sh
set -e
bundle exec rake assets:precompile RAILS_ENV=production
bundle exec rake db:create RAILS_ENV=production
bundle exec rake db:migrate RAILS_ENV=production
rm -f /app/tmp/pids/server.pid
exec "$@"