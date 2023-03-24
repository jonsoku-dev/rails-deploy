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
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN gem install bundler:2.2.28 && \
    bundle config set without 'development test' && \
    bundle config set path 'vendor/bundle' && \
    bundle install --jobs "$(nproc)" --retry 5

# Copy the rest of the application code
COPY . .

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Precompile assets
RUN bundle exec rake assets:precompile RAILS_ENV=production

#RUN bundle exec rake db:create RAILS_ENV=production
#RUN bundle exec rake db:migrate RAILS_ENV=production
#RUN bundle exec rake db:seed RAILS_ENV=production

# Expose port and start the server
EXPOSE 3050
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]