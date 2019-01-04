# frozen_string_literal: true

class CreateReplies < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_RESPOSTA, id: false do |t|
      t.bigint :CO_SEQ_ID
      t.string :DS_DESCRICAO, null: false
      t.bigint :CO_CATEGORIA, null: false
      t.string :ST_FAQ, limit: 1, null: false, default: 'N'
      t.string :repliable_type, null: false
      t.bigint :CO_PROTOCOLO, null: false
      t.bigint :CO_USUARIO, null: false
      t.integer :TP_STATUS, null: false
      t.datetime :DT_CRIADO_EM
      t.datetime :DT_REF_ATENDIMENTO_FECHADO
      t.datetime :DT_REF_ATENDIMENTO_REABERTO
    end

    add_foreign_key :TB_RESPOSTA, :users, column: :CO_USUARIO

    execute <<-SQL
      CREATE SEQUENCE "SQ_RESPOSTA_ID";
      ALTER TABLE "TB_RESPOSTA" ADD CONSTRAINT "PK_TB_RESPOSTA" PRIMARY KEY ("CO_SEQ_ID");
      ALTER TABLE "TB_RESPOSTA" ALTER COLUMN "CO_SEQ_ID" SET DEFAULT nextval('"SQ_RESPOSTA_ID"');
      -- ALTER SEQUENCE TB_QUESTAO_CO_SEQ_ID_SEQ OWNED BY NONE;
      ALTER SEQUENCE "SQ_RESPOSTA_ID" OWNED BY "TB_RESPOSTA"."CO_SEQ_ID";
    SQL
  end

  def self.down
    execute 'ALTER TABLE "TB_RESPOSTA" DROP CONSTRAINT "PK_TB_RESPOSTA";'
    drop_table :TB_RESPOSTA
  end
end
