# frozen_string_literal: true

class CreateUnities < ActiveRecord::Migration[5.2]
  def change
    create_table :unities, id: false do |t|
      t.integer :cnes, null: false
      t.string :name
      t.references :city, foreign_key: true

      t.timestamps
    end
    add_index :unities, :cnes, unique: true
  end
end
