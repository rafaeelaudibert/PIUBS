# frozen_string_literal: true

class UpdateUsers < ActiveRecord::Migration[5.2]
  def self.up
    change_table :TB_USUARIO do |t|
      t.string :NO_NOME
      t.string :NO_SOBRENOME
      t.string :NU_CPF
      t.integer :TP_ROLE
      t.bigint :ST_SISTEMA
      t.bigint :CO_CIDADE
      t.bigint :CO_SEI
      t.bigint :CO_CNES
    end

    add_foreign_key :TB_USUARIO, :TB_CIDADE, column: :CO_CIDADE, primary_key: :CO_CODIGO, name: 'FK_CIDADE_USUARIO'
    add_foreign_key :TB_USUARIO, :TB_UBS, column: :CO_CNES, primary_key: :CO_CNES, name: 'FK_UBS_USUARIO'
    add_foreign_key :TB_USUARIO, :TB_EMPRESA, column: :CO_SEI, primary_key: :CO_SEI, name: 'FK_EMPRESA_USUARIO'
    add_index :TB_USUARIO, :CO_CIDADE, name: "IN_FKUSUARIO_COCIDADE"
    add_index :TB_USUARIO, :CO_CNES, name: "IN_FKUSUARIO_COCNES"
    add_index :TB_USUARIO, :CO_SEI, name: "IN_FKUSUARIO_COSEI"
  end

  def self.down
    remove_index :TB_USUARIO, name: "IN_FKUSUARIO_COCIDADE"
    remove_index :TB_USUARIO, name: "IN_FKUSUARIO_COCNES"
    remove_index :TB_USUARIO, name: "IN_FKUSUARIO_COSEI"
    remove_foreign_key :TB_USUARIO, name: 'FK_CIDADE_USUARIO'
    remove_foreign_key :TB_USUARIO, name: 'FK_UBS_USUARIO'
    remove_foreign_key :TB_USUARIO, name: 'FK_EMPRESA_USUARIO'
  end
end
