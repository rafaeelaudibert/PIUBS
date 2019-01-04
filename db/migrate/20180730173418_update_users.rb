# frozen_string_literal: true

class UpdateUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :name, :string
    add_column :users, :role, :integer
    add_column :users, :cpf, :string
    add_column :users, :last_name, :string
    add_column :users, :system, :bigint
  end
end
