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


ARG RAILS_MASTER_KEY
ARG RAILS_SECRET
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE="echo 'export rails secret'"
ENV RAILS_MASTER_KEY=$RAILS_MASTER_KEY
RUN echo "$RAILS_MASTER_KEY" >> config/master.key
RUN export SECRET_KEY_BASE=$RAILS_SECRET

# Precompile assets
RUN bundle exec rake assets:precompile --trace RAILS_ENV=production

# Expose port and start the server
EXPOSE 3050
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
