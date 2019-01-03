# frozen_string_literal: true

class AddDefaultValuesToTables < ActiveRecord::Migration[5.2]
  def change
    change_column :controversies, :status, :integer, default: 0       # Open!
    change_column :controversies, :complexity, :integer, default: 1   # Complexidade inicial 1
  end
end
