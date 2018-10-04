# frozen_string_literal: true

class EditCalls < ActiveRecord::Migration[5.2]
  def change
    remove_column :calls, :severity
    add_column :calls, :severity, :integer
  end
end
