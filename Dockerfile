# Use an official Ruby runtime as a parent image
FROM ruby:3.1.2

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    build-essential \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    libsqlite3-dev \
    sqlite3 \
    libmariadb-dev \
    mariadb-client \
    tzdata \
    nodejs

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn

# Set the working directory
WORKDIR /app

# Copy the Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./


# Install gems
RUN gem install bundler && \
    bundle config set without 'development test' && \
    bundle install

# Copy the rest of the application code
COPY . .

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# DB
RUN bundle exec rake db:create
RUN bundle exec rake db:migrate
#RUN bundle exec rake db:seed

# Precompile assets
RUN bundle exec rake assets:precompile --trace RAILS_ENV=production

# Expose port and start the server
EXPOSE 3050
#CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3050"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]