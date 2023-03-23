# Use an official Ruby runtime as a parent image
FROM ruby:3.1.2-alpine

# Install dependencies
RUN apt-get update && \
    apt-get add --no-cache \
        build-base \
        mariadb-dev \
        tzdata \
        git
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -\
  && apt-get update -qq && apt-get install -qq --no-install-recommends \
    nodejs \
  && apt-get upgrade -qq \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*\
  && npm install -g yarn

# Set the working directory
WORKDIR /app

# Copy the Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN gem install rails -v 6.1.7
RUN bundle install --without development test

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
RUN RAILS_ENV=production rails assets:precompile

EXPOSE 3050

# Start the server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]