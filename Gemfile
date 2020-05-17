# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
ruby '2.6.0'

# Development only gems
group :development do
  gem 'any_login', '>= 1.3.1'
  gem 'better_errors', '>= 2.5.0'
  gem 'binding_of_caller'
  gem 'brakeman'
  gem 'github_changelog_generator'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rails_layout'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.7.0'
end

# Tests only gems
group :test do
  gem 'capybara', '>= 3.12.0', '< 4.0'
  gem 'chromedriver-helper'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'selenium-webdriver'
end

# Development + Tests only gems
group :development, :test do
  gem 'awesome_rails_console', '>= 0.4.3'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', '>= 4.11.1'
  gem 'faker'
  gem 'hirb'
  gem 'hirb-unicode-steakknife', require: 'hirb-unicode'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
  gem 'rspec-rails', '>= 3.8.1'
end

# mysql2 is required for production
group :production do
  gem 'mysql2'
end

# Default gems
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bootstrap', '>= 4.3.1'
gem 'carrierwave'
gem 'coffee-rails', '~> 4.2', '>= 4.2.2'
gem 'devise', '>= 4.7.1'
gem 'devise-async', '>= 1.0.0'
gem 'devise_invitable', '>= 1.7.5'
gem 'high_voltage'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails', '>= 4.3.3'
gem 'jquery-ui-rails', '>= 6.0.1'
gem 'json', '>= 2.3.0'
gem 'logging'
gem 'pg'
gem 'popper_js', '~> 1.14.3'
gem 'puma', '~> 3.12'
gem 'rails', '~> 5.2.4', '>= 5.2.4.2'
gem 'rambulance', '>= 0.6.0'
gem 'sass-rails', '~> 5.0', '>= 5.0.7'
gem 'sidekiq', '>= 5.2.3'
gem 'sqlite3'
gem 'turbolinks', '~> 5.2.0'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'uglifier', '>= 1.3.0'

# PIUBS specific gems
gem 'backup'
gem 'cancancan', '~> 2.0'                   # Authorization library
gem 'cpf_cnpj'                              # CPF/CNPJ validations/management
gem 'data-confirm-modal', '>= 1.6.2'        # Modals for confimations
gem 'dropzonejs-rails', '>= 0.8.4'          # Attachments drag n'drop functionality
gem 'filterrific', '~> 5.1.0'               # Filtering
gem 'font-awesome-rails', '>= 4.7.0.4'      # Icons
gem 'mail_form', '>= 1.7.1'                 # Mailer gem
gem 'mini_racer'                            # Fix "Autoprefixer doesn't support Node v4.2.6"
gem 'pg_search'                             # Full-text search gem
gem 'rails-jquery-autocomplete', '>= 1.0.5' # Auto complete
gem 'shog', '>= 0.2.1'                      # Colorized console logging
gem 'tinymce-rails', '>= 4.9.2'             # WSYCWYG Text Editor
gem 'tinymce-rails-langs', '>= 4.20180103'  # Language packs for TinyMCE Text Editor
gem 'validators'                            # Validators, such as CPF/e-mail
gem 'whenever', require: false              # Cron-like jobs
gem 'will_paginate', '~> 3.1.0'             # Pagination
gem 'will_paginate-bootstrap4'              # Bootstrap for pagination
