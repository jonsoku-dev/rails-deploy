# Use an official Ruby runtime as a parent image
FROM ruby:3.1.2-alpine

# Install dependencies
RUN apk update
RUN apk add build-base \
        mariadb-dev \
        tzdata \
        git
RUN apk add bash curl nodejs
RUN touch ~/.bashrc \
    && curl -o- -L https://yarnpkg.com/install.sh | bash \
    && ln -s "$HOME/.yarn/bin/yarn" /usr/local/bin/yarn

RUN yarn --version

# Set the working directory
WORKDIR /app

# Copy the Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN gem install rails -v 6.1.7
RUN gem install bundler
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