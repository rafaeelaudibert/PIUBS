# frozen_string_literal: true

class EditUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :cpf
    add_column :users, :cpf, :string
    add_column :users, :CO_CIDADE, :integer
    add_foreign_key :users, :TB_CIDADE, column: :CO_CIDADE, primary_key: :CO_CODIGO
    add_column :users, :CO_CNES, :integer
    add_foreign_key :users, :TB_UBS, column: :CO_CNES, primary_key: :CO_CNES
    add_column :users, :last_name, :string
    add_column :users, :system, :integer
  end
end
