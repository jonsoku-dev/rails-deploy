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

# Run database migrations
RUN rails db:migrate

# Expose port 3000
EXPOSE 3000

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
