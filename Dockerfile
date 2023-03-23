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
ENV RAILS_ENV=production
ENV RAILS_MASTER_KEY=$RAILS_MASTER_KEY
RUN echo "$RAILS_MASTER_KEY" >> config/master.key

# Expose port 3000
EXPOSE 3000

# Start the Rails server
CMD ["rails", "server"]
