# Use an official Ruby runtime as a parent image
FROM ruby:3.1.2-alpine

# Install dependencies
RUN apk update && \
    apk add --no-cache \
        build-base \
        mysql-dev \
        tzdata \
        git

# Set the working directory
WORKDIR /app

# Copy the Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle config set deployment true && \
    bundle install --without development test

# Copy the rest of the application code
COPY . .

# Precompile assets
RUN bundle exec rake assets:precompile

EXPOSE 3050

# Start the server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]