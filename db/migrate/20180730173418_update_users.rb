# frozen_string_literal: true

class UpdateUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :TB_USUARIO do |t|
      t.string :NO_NOME
      t.string :NO_SOBRENOME
      t.string :NU_CPF
      t.integer :TP_ROLE
      t.bigint :ST_SISTEMA
    end
  end
end
