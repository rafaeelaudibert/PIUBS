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
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
end

# Default gems
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bootstrap', '~> 4.1.2'
gem 'carrierwave'
gem 'coffee-rails', '~> 4.2'
gem 'devise'
gem 'devise_invitable'
gem 'high_voltage'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'json'
gem 'pg'
gem 'puma', '~> 3.11'
gem 'rails', '~> 5.2.1'
gem 'sass-rails', '~> 5.0'
gem 'sqlite3'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'uglifier', '>= 1.3.0'

# PIUBS specific gems
gem "cpf_cnpj"                  # CPF/CNPJ validations/management
gem "font-awesome-rails"        # Icons
gem "mail_form", ">= 1.3.0"     # Mailer gem
gem "mini_racer"                # Fix "Autoprefixer doesn’t support Node v4.2.6"
gem "validators"                # Validators, such as CPF/e-mail
gem 'data-confirm-modal'        # Modals for confimations
gem 'pg_search'                 # Full-text search gem
gem 'shog'                      # Colorized console logging
gem 'tinymce-rails'             # WSYCWYG Text Editor
gem 'tinymce-rails-langs'       # Translate tinymce
gem 'will_paginate', '~> 3.1.0' # Pagination
gem 'filterrific', '~> 5.1.0'     # Filtering
