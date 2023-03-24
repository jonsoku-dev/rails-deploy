# Use an official Ubuntu 18.04 LTS image as a parent image
FROM ubuntu:18.04

# Update packages and install necessary dependencies
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

# Install rbenv and set environment variables
ENV PATH="/root/.rbenv/bin:/root/.rbenv/shims:$PATH"
RUN curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-installer | bash && \
    echo 'eval "$(rbenv init -)"' >> /root/.bashrc && \
    rbenv install 3.1.2 && \
    rbenv global 3.1.2

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

# Precompile assets
RUN bundle exec rails assets:precompile

# Expose port and start the server
EXPOSE 3050
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
