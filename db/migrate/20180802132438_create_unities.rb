# frozen_string_literal: true

class CreateUnities < ActiveRecord::Migration[5.2]
  def change
    create_table :unities, id: false do |t|
      t.integer :cnes, null: false
      t.string :name
      t.integer :CO_CIDADE

      t.timestamps
    end
    add_foreign_key :unities, :TB_CIDADE, column: :CO_CIDADE, primary_key: :CO_CODIGO
    add_index :unities, :cnes, unique: true
  end
end
