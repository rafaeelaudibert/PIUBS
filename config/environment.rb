# frozen_string_literal: true

require_relative 'application' # Load the Rails application.
require 'logging' # Require logging

# Initialize the Rails application.
Rails.application.initialize!

####
# Logging Configuration
##

# Color scheme configuration
Logging.color_scheme('default',
                     levels: {
                       debug: :bright_white,
                       info: :bright_green,
                       warn: :brigt_yellow,
                       error: :bright_red,
                       fatal: %i[white on_red]
                     },
                     date: :bright_blue,
                     logger: :bright_cyan,
                     message: :white)

# Appenders configuration
Logging.appenders.stdout(
  'stdout',
  layout: Logging.layouts.pattern(
    pattern: '[%d] %-5l %c: %m\n',
    color_scheme: 'default'
  )
)

Logging.appenders.rolling_file(
  './log/logging.log',
  layout: Logging.layouts.pattern(pattern: '[%d] %-5l %c: %m\n'),
  options: { age: 'weekly', roll_by: 'date' }
)

# Logger on the Database related logging
model_logger = Logging.logger['MDL']
model_logger.level = :debug
model_logger.add_appenders(
  Logging.appenders.stdout,
  Logging.appenders.rolling_file('./log/logging.log')
)
ActiveRecord::Base.logger = model_logger

# Logger used on Controller related logging
controller_logger = Logging.logger['CTL']
controller_logger.level = :debug
controller_logger.add_appenders(
  Logging.appenders.stdout,
  Logging.appenders.rolling_file('./log/logging.log')
)
ActionController::Base.logger = controller_logger
