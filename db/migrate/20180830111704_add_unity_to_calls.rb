# frozen_string_literal: true

class AddUnityToCalls < ActiveRecord::Migration[5.2]
  def change
    add_column :calls, :cnes, :integer
    add_foreign_key :calls, :unities, column: :cnes, primary_key: :cnes
  end
end
