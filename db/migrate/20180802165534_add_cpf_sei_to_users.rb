# frozen_string_literal: true

class AddCpfSeiToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :cpf, :integer
    add_column :users, :CO_SEI, :bigint
    add_foreign_key :users, :TB_EMPRESA, column: :CO_SEI, primary_key: :CO_SEI
  end
end
