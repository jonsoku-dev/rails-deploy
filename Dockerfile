# Use an official Ruby runtime as a parent image
FROM ruby:3.1.2

# Install dependencies
RUN apt-get update && \
    apt-get install -y libmariadbclient-dev tzdata git nodejs curl && \
    rm -rf /var/lib/apt/lists/*

# Install yarn
RUN curl -o- -L https://yarnpkg.com/install.sh | bash && \
    ln -s "$HOME/.yarn/bin/yarn" /usr/local/bin/yarn

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

# Set environment variables
ARG RAILS_MASTER_KEY
ARG RAILS_SECRET
ENV RAILS_ENV=production \
    SECRET_KEY_BASE="$(echo 'export rails secret')" \
    RAILS_MASTER_KEY=$RAILS_MASTER_KEY

# Add RAILS_MASTER_KEY to config/master.key
RUN echo "$RAILS_MASTER_KEY" >> config/master.key

# Set SECRET_KEY_BASE
RUN export SECRET_KEY_BASE=$RAILS_SECRET

# Precompile assets
RUN rails assets:precompile

EXPOSE 3050

# Start the server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
