# frozen_string_literal: true

class CreateContracts < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_CONTRATO, id: false do |t|
      t.bigint :CO_CODIGO, null: false
      t.bigint :CO_CIDADE, null: false
      t.bigint :CO_SEI, null: false
      t.string :NO_NOME_ARQUIVO, null: false
      t.string :DS_TIPO_ARQUIVO, null: false
      t.binary :BL_CONTEUDO, limit: 25.megabytes, null: false
      t.datetime :DT_CRIADO_EM
    end

    execute 'ALTER TABLE "TB_CONTRATO" ADD CONSTRAINT "PK_TB_CONTRATO" PRIMARY KEY ("CO_CODIGO");'
    add_foreign_key :TB_CONTRATO, :TB_CIDADE, column: :CO_CIDADE, primary_key: :CO_CODIGO, name: 'FK_CIDADE_CONTRATO'
    add_foreign_key :TB_CONTRATO, :TB_EMPRESA, column: :CO_SEI, primary_key: :CO_SEI, name: 'FK_EMPRESA_CONTRATO'
    add_index :TB_CONTRATO, :CO_CIDADE, name: "IN_FKCONTRATO_COCIDADE"
    add_index :TB_CONTRATO, :CO_SEI, name: "IN_FKCONTRATO_COSEI"
  end

  def self.down
    remove_index :TB_CONTRATO, name: "IN_FKCONTRATO_COCIDADE"
    remove_index :TB_CONTRATO, name: "IN_FKCONTRATO_COSEI"
    remove_foreign_key :TB_CONTRATO, name: 'FK_CIDADE_CONTRATO'
    remove_foreign_key :TB_CONTRATO, name: 'FK_EMPRESA_CONTRATO'
    drop_table :TB_CONTRATO
  end
end
