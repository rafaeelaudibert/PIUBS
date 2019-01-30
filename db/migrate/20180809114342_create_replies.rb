# frozen_string_literal: true

class CreateReplies < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_RESPOSTA, id: false do |t|
      t.bigint :CO_ID
      t.string :DS_DESCRICAO, null: false
      t.string :ST_FAQ, limit: 1, null: false, default: 'N'
      t.datetime :DT_CRIADO_EM
    end

    execute <<-SQL
      -- PK
      ALTER TABLE "TB_RESPOSTA" ADD CONSTRAINT "PK_TB_RESPOSTA" PRIMARY KEY ("CO_ID");

      -- FK
      ALTER TABLE "TB_RESPOSTA" ADD CONSTRAINT "FK_EVENTO_RESPOSTA" FOREIGN KEY ("CO_ID")
        REFERENCES public."TB_EVENTO" ("CO_SEQ_ID") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;
    SQL
  end

  def self.down
    execute <<-SQL
      ALTER TABLE "TB_RESPOSTA" DROP CONSTRAINT "FK_EVENTO_RESPOSTA";
      ALTER TABLE "TB_RESPOSTA" DROP CONSTRAINT "PK_TB_RESPOSTA";
    SQL

    drop_table :TB_RESPOSTA
  end
end
