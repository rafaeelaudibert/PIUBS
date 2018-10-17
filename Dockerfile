# Base image:
FROM ruby:2.5.1

# Configure postgres repository
RUN touch /etc/apt/sources.list.d/pgdg.list
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN apt-get install -y cron
RUN apt-get install -y postgresql-client-10


# Set an environment variable where the Rails app is installed to inside of Docker image:
ENV RAILS_ROOT /var/www/PIUBS
RUN mkdir -p $RAILS_ROOT

# Set working directory, where the commands will be ran:
WORKDIR $RAILS_ROOT

# Gems:
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN gem install bundler
RUN bundle install -j 20

# Configure backup
RUN backup generate:model --trigger PIUBS_production --archives --storages='local' --compressors='gzip' --notifiers='mail' --databases='postgresql'
COPY db/backup.rb /root/Backup/models/PIUBS_production.rb
RUN backup dependencies --install mail
RUN mkdir /root/backups

# Copy the main application.
COPY config/puma.rb config/puma.rb
COPY . .

# Configure whenever
RUN wheneverize
COPY db/whenever.rb config/schedule.rb
RUN whenever --update-crontab

EXPOSE 3000

# The default command that gets ran will be to start the Puma server.
CMD bundle exec puma -C config/puma.rb -e production
