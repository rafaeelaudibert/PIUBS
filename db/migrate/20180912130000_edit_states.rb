# frozen_string_literal: true

class EditStates < ActiveRecord::Migration[5.2]
  def change
    add_column :states, :abbr, :string
  end
end
