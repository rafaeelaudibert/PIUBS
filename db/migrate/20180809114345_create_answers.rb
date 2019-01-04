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

    add_foreign_key :TB_QUESTAO, :TB_CATEGORIA, column: :CO_CATEGORIA, primary_key: :CO_SEQ_ID
    add_foreign_key :TB_QUESTAO, :TB_USUARIO, column: :CO_USUARIO

    execute <<-SQL
      CREATE SEQUENCE "SQ_QUESTAO_ID";
      ALTER TABLE "TB_QUESTAO" ADD CONSTRAINT "PK_TB_QUESTAO" PRIMARY KEY ("CO_SEQ_ID");
      ALTER TABLE "TB_QUESTAO" ALTER COLUMN "CO_SEQ_ID" SET DEFAULT nextval('"SQ_QUESTAO_ID"');
      -- ALTER SEQUENCE TB_QUESTAO_CO_SEQ_ID_SEQ OWNED BY NONE;
      ALTER SEQUENCE "SQ_QUESTAO_ID" OWNED BY "TB_QUESTAO"."CO_SEQ_ID";
    SQL
  end

  def self.down
    execute 'ALTER TABLE "TB_QUESTAO" DROP CONSTRAINT "PK_TB_QUESTAO";'
    drop_table :TB_QUESTAO
  end
end
