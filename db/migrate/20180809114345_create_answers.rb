# frozen_string_literal: true

class CreateAnswers < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_QUESTAO, id: false do |t|
      t.bigint :CO_SEQ_ID, null: false
      t.text :DS_QUESTAO, null: false
      t.text :DS_RESPOSTA, null: false
      t.bigint :CO_CATEGORIA, null: false
      t.bigint :CO_USUARIO, null: false
      t.string :ST_FAQ, limit: 1, null: false, default: 'N'
      t.string :DS_PALAVRA_CHAVE, null: false
      t.bigint :CO_SISTEMA_ORIGEM, null: false
      t.datetime :DT_CRIADO_EM
    end

    execute <<-SQL
      -- Sequence
      CREATE SEQUENCE "SQ_QUESTAO_ID";
      ALTER TABLE "TB_QUESTAO" ALTER COLUMN "CO_SEQ_ID" SET DEFAULT nextval('"SQ_QUESTAO_ID"');
      ALTER SEQUENCE "SQ_QUESTAO_ID" OWNED BY "TB_QUESTAO"."CO_SEQ_ID";

      -- PK
      ALTER TABLE "TB_QUESTAO" ADD CONSTRAINT "PK_TB_QUESTAO" PRIMARY KEY ("CO_SEQ_ID");

      -- FK
      ALTER TABLE "TB_QUESTAO" ADD CONSTRAINT "FK_SISTEMA_QUESTAO" FOREIGN KEY ("CO_SISTEMA_ORIGEM")
        REFERENCES "TB_SISTEMA" ("CO_SEQ_ID") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;

      ALTER TABLE "TB_QUESTAO" ADD CONSTRAINT "FK_USUARIO_QUESTAO" FOREIGN KEY ("CO_USUARIO")
        REFERENCES "TB_USUARIO" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;

      ALTER TABLE "TB_QUESTAO" ADD CONSTRAINT "FK_CATEGORIA_QUESTAO" FOREIGN KEY ("CO_CATEGORIA")
        REFERENCES "TB_CATEGORIA" ("CO_SEQ_ID") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;
    SQL
  end

  def self.down
    execute <<-SQL
      ALTER TABLE "TB_QUESTAO" DROP CONSTRAINT "FK_SISTEMA_QUESTAO";
      ALTER TABLE "TB_QUESTAO" DROP CONSTRAINT "FK_USUARIO_QUESTAO";
      ALTER TABLE "TB_QUESTAO" DROP CONSTRAINT "FK_CATEGORIA_QUESTAO";
      ALTER TABLE "TB_QUESTAO" DROP CONSTRAINT "PK_TB_QUESTAO";
    SQL

    drop_table :TB_QUESTAO
  end
end
