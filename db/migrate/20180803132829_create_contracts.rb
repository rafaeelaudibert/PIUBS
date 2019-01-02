# frozen_string_literal: true

class CreateContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :contracts do |t|
      t.json :files
      t.integer :contract_number
      t.integer :CO_CIDADE
      t.integer :CO_SEI

      t.timestamps
    end

    add_foreign_key :contracts, :TB_CIDADE, column: :CO_CIDADE, primary_key: :CO_CODIGO
    add_foreign_key :contracts, :TB_EMPRESA, column: :CO_SEI, primary_key: :CO_SEI
  end
end
