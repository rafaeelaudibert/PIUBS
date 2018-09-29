# frozen_string_literal: true

class CreateContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :contracts do |t|
      t.json :files
      t.integer :contract_number
      t.references :city, foreign_key: true
      t.integer :sei

      t.timestamps
    end

    add_foreign_key :contracts, :companies, column: :sei, primary_key: :sei
  end
end
