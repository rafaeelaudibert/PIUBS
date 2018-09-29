# frozen_string_literal: true

class AddCpfSeiToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :cpf, :integer
    add_column :users, :sei, :integer
    add_foreign_key :users, :companies, column: :sei, primary_key: :sei
  end
end
