# frozen_string_literal: true

class CreateCities < ActiveRecord::Migration[5.2]
  def change
    create_table :cities do |t|
      t.string :name
      t.integer :CO_UF

      t.timestamps
    end

    add_foreign_key :cities, :TB_UF, column: :CO_UF, primary_key: :CO_CODIGO
  end
end
