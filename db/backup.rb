# encoding: utf-8

##
# Backup Generated: PIUBS_production
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t PIUBS_production [-c <path_to_configuration_file>]
#
Backup::Model.new(:PIUBS_production, 'Daily Backup') do
  ##
  # Split [Splitter]
  #
  # Split the backup file in to chunks of 250 megabytes
  # if the backup file size exceeds 250 megabytes
  #
  split_into_chunks_of 250

  ##
  # PostgreSQL [Database]
  #
  database PostgreSQL do |db|
    db.name               = "piubs_production"
    db.username           = "postgres"
    db.host               = "db"
    db.password           = "19550410"
    db.port               = 5432
  end

  ##
  # Local (Copy) [Storage]
  #
  store_with Local do |local|
    local.path       = "~/backups/"
    local.keep       = 5
  end

  ##
  # Gzip [Compressor]
  #
  compress_with Gzip

  ##
  # Mail [Notifier]
  #
  # The default delivery method for Mail Notifiers is 'SMTP'.
  # See the Wiki for other delivery options.
  # https://github.com/meskyanichi/backup/wiki/Notifiers
  #
  notify_by Mail do |mail|
    mail.on_success           = true
    mail.on_warning           = true
    mail.on_failure           = true

    mail.from                 = "backup@piubs.com"
    mail.to                   = "mario.ufrgs.inf@gmail.com"
    mail.address              = "smtp.gmail.com"
    mail.port                 = 587
    mail.domain               = "localhost:3000"
    mail.user_name            = "apoio.piubs@gmail.com"
    mail.password             = "piubs@ufrgs123"
    mail.authentication       = "plain"
    mail.encryption           = :starttls
  end

end
