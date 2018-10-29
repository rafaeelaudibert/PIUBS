# frozen_string_literal: true

class AddDefaultValuesToTables < ActiveRecord::Migration[5.2]
  def change
    change_column :controversies, :status, :integer, default: 0       # Open!
    change_column :controversies, :complexity, :integer, default: 1   # Complexidade inicial 1
    change_column :calls, :severity, :integer, default: 1             # Severidade normal
    change_column :calls, :status, :integer, default: 0               # Open!
  end
end
