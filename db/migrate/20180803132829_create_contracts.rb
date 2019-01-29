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

    execute <<-SQL
      ALTER TABLE "TB_CONTRATO" ADD CONSTRAINT "PK_TB_CONTRATO" PRIMARY KEY ("CO_CODIGO");

      ALTER TABLE "TB_CONTRATO" ADD CONSTRAINT "PK_EMPRESA_CONTRATO" FOREIGN KEY ("CO_SEI")
        REFERENCES "TB_EMPRESA" ("CO_SEI") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;

      ALTER TABLE "TB_CONTRATO" ADD CONSTRAINT "PK_CIDADE_CONTRATO" FOREIGN KEY ("CO_CIDADE")
        REFERENCES "TB_CIDADE" ("CO_CODIGO") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;

    SQL
  end

  def self.down
    execute <<-SQL
      ALTER TABLE "TB_CONTRATO" DROP CONSTRAINT "PK_TB_CONTRATO";
      ALTER TABLE "TB_CONTRATO" DROP CONSTRAINT "PK_EMPRESA_CONTRATO";
      ALTER TABLE "TB_CONTRATO" DROP CONSTRAINT "PK_CIDADE_CONTRATO";
    SQL
    drop_table :TB_CONTRATO
  end
end
