# frozen_string_literal: true

class ConfigureExtensions < ActiveRecord::Migration[5.2]
  def up
    execute 'CREATE EXTENSION IF NOT EXISTS pg_trgm;'
    execute 'CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;'
    execute 'CREATE EXTENSION IF NOT EXISTS unaccent;'
    enable_extension 'uuid-ossp'
  end

  def down
    execute 'DROP EXTENSION IF EXISTS pg_trgm;'
    execute 'DROP EXTENSION IF EXISTS fuzzystrmatch;'
    execute 'DROP EXTENSION IF EXISTS unaccent;'
    disable_extension 'uuid-ossp'
  end
end
