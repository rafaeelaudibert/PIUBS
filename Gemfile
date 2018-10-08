# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
ruby '2.5.1'

# Development only gems
group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'brakeman'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rails_layout'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

# Tests only gems
group :test do
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'chromedriver-helper'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'selenium-webdriver'
end

# Development + Tests only gems
group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
end

# mysql2 is required for production
group :production do
  gem 'mysql2'
end

# Default gems
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bootstrap', '~> 4.1.3'
gem 'carrierwave'
gem 'coffee-rails', '~> 4.2'
gem 'devise'
gem "devise-async"
gem 'devise_invitable'
gem 'high_voltage'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'json'
gem 'pg'
gem 'popper_js', '~> 1.14.3'
gem 'puma', '~> 3.11'
gem 'rails', '~> 5.2.1'
gem 'sass-rails', '~> 5.0'
gem 'sidekiq'
gem 'sqlite3'
gem 'turbolinks', '~> 5.2.0'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'uglifier', '>= 1.3.0'

# PIUBS specific gems
gem 'backup'
gem 'whenever', require: false
gem 'cpf_cnpj'                  # CPF/CNPJ validations/management
gem 'data-confirm-modal'        # Modals for confimations
gem 'filterrific', '~> 5.1.0'   # Filtering
gem 'font-awesome-rails'        # Icons
gem 'mail_form', '>= 1.3.0'     # Mailer gem
gem 'mini_racer'                # Fix "Autoprefixer doesn’t support Node v4.2.6"
gem 'pg_search'                 # Full-text search gem
gem 'shog'                      # Colorized console logging
gem 'tinymce-rails'             # WSYCWYG Text Editor
gem 'tinymce-rails-langs'       # Language packs for TinyMCE Text Editor
gem 'validators'                # Validators, such as CPF/e-mail
gem 'will_paginate', '~> 3.1.0' # Pagination
