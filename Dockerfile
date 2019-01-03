# Base image:
FROM ruby:2.6.0

# Install dependencies and clean lists
RUN apt-get update -qq && apt-get install -y --no-install-recommends build-essential libpq-dev \
    nodejs && apt-get clean && rm -rf /var/lib/apt/list/*

# Set an environment variable where the Rails app is installed to inside of Docker image:
ENV RAILS_ROOT /var/www/PIUBS
RUN mkdir -p $RAILS_ROOT

# Set working directory, where the commands will be ran:
WORKDIR $RAILS_ROOT

# Copy the main application.
COPY . .

# Install gems
RUN gem install bundler
RUN bundle install -j 20

EXPOSE 3000
