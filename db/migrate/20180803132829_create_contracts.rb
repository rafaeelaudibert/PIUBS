# frozen_string_literal: true

class CreateContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :contracts do |t|
      t.json :files
      t.integer :contract_number
      t.references :city, foreign_key: true
      t.integer :CO_SEI

      t.timestamps
    end

    add_foreign_key :contracts, :TB_EMPRESA, column: :CO_SEI, primary_key: :CO_SEI
  end
end
