# frozen_string_literal: true

class CreateFeedbacks < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_FEEDBACK, id: false do |t|
      t.bigint :CO_PROTOCOLO, null: false
      t.text :DS_DESCRICAO, null: false
      t.datetime :DT_CRIADO_EM
    end

    execute <<-SQL
      -- PK
      ALTER TABLE "TB_FEEDBACK" ADD CONSTRAINT "PK_TB_FEEDBACK" PRIMARY KEY ("CO_PROTOCOLO");

      -- FK
      ALTER TABLE "TB_FEEDBACK" ADD CONSTRAINT "FK_CONTROVERSIA_FEEDBACK" FOREIGN KEY ("CO_PROTOCOLO")
        REFERENCES "TB_CONTROVERSIA" ("CO_PROTOCOLO") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
    SQL
  end

  def self.down
    execute <<-SQL
      ALTER TABLE "TB_FEEDBACK" DROP CONSTRAINT "FK_CONTROVERSIA_FEEDBACK";
      ALTER TABLE "TB_FEEDBACK" DROP CONSTRAINT "PK_TB_FEEDBACK";
    SQL

    drop_table :TB_FEEDBACK
  end
end
