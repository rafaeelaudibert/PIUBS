# frozen_string_literal: true

class CreateUnities < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_UBS, id: false do |t|
      t.bigint :CO_CNES, null: false
      t.string :NO_NOME, null: false
      t.bigint :CO_CIDADE, null: false
      t.string :DS_ENDERECO, default: ''
      t.string :DS_BAIRRO, default: ''
      t.string :DS_TELEFONE, default: ''
    end

    execute <<-SQL
      ALTER TABLE "TB_UBS" ADD CONSTRAINT "PK_TB_UBS" PRIMARY KEY ("CO_CNES");

      ALTER TABLE "TB_UBS" ADD CONSTRAINT "FK_CIDADE_UBS" FOREIGN KEY ("CO_CIDADE")
        REFERENCES "TB_CIDADE" ("CO_CODIGO") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;
    SQL
  end

  def self.down
    execute <<-SQL
      ALTER TABLE "TB_UBS" DROP CONSTRAINT "PK_TB_UBS";
      ALTER TABLE "TB_UBS" DROP CONSTRAINT "FK_CIDADE_UBS";
    SQL
    drop_table :TB_UBS
  end
end
