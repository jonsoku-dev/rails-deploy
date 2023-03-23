# Use an official Ruby runtime as a parent image
FROM ruby:3.1.2-alpine

# Install dependencies
RUN apk update && \
    apk add --no-cache \
        build-base \
        mariadb-dev \
        tzdata \
        git

# Set the working directory
WORKDIR /app

# Copy the Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN gem install rails -v 6.1.7
RUN bundle install --without development test

# Copy the rest of the application code
COPY . .

# Precompile assets
RUN RAILS_ENV=production bin/rails assets:precompile

EXPOSE 3050

# Start the server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]