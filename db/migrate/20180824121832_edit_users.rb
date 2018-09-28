# frozen_string_literal: true

class EditUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :cpf
    add_column :users, :cpf, :string
    add_reference :users, :city, foreign_key: true
    add_column :users, :cnes, :integer
    add_foreign_key :users, :unities, column: :cnes, primary_key: :cnes
  end
end
