# Base image
FROM ruby:3.1.2

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y nodejs mariadb-client # https://qiita.com/aseanchild1400/items/d3580366054fee3d2703

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy the rest of the application code
COPY . .

# Set environment variables
ARG RAILS_MASTER_KEY
ARG RAILS_SECRET
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE="echo 'export rails secret'"
ENV RAILS_MASTER_KEY=$RAILS_MASTER_KEY
RUN echo "$RAILS_MASTER_KEY" >> config/master.key
RUN export SECRET_KEY_BASE=$RAILS_SECRET
RUN RAILS_ENV=$RAILS_ENV rails assets:precompile
# Expose port 3000
EXPOSE 3000

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0", "-e", "production"]
