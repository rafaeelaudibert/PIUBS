# frozen_string_literal: true

class CreateContracts < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_CONTRATO, id: false do |t|
      t.integer :CO_CODIGO
      t.integer :CO_CIDADE
      t.integer :CO_SEI
      t.string :NO_ARQUIVO
      t.string :DS_TIPO_ARQUIVO
      t.binary :BL_CONTEUDO, limit: 25.megabytes
      t.datetime :DT_CRIADO_EM
    end

    add_foreign_key :TB_CONTRATO, :TB_CIDADE, column: :CO_CIDADE, primary_key: :CO_CODIGO
    add_foreign_key :TB_CONTRATO, :TB_EMPRESA, column: :CO_SEI, primary_key: :CO_SEI

    execute 'ALTER TABLE "TB_CONTRATO" ADD CONSTRAINT "PK_TB_CONTRATO" PRIMARY KEY ("CO_CODIGO");'
  end

  def self.down
    execute 'ALTER TABLE "TB_CONTRATO" DROP CONSTRAINT "PK_TB_CONTRATO";'
    drop_table :TB_CONTRATO
  end
end
