# frozen_string_literal: true

class CreateAlteration < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_ALTERACAO, id: false do |t|
      t.bigint :CO_ID
      t.bigint :CO_TIPO
    end

    execute <<-SQL
    -- PK
    ALTER TABLE "TB_ALTERACAO" ADD CONSTRAINT "PK_TB_ALTERACAO" PRIMARY KEY ("CO_ID");

    -- FK
    ALTER TABLE "TB_ALTERACAO" ADD CONSTRAINT "FK_EVENTO_ALTERACAO" FOREIGN KEY ("CO_ID")
        REFERENCES "TB_EVENTO" ("CO_SEQ_ID") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;
    SQL
  end

  def self.down
    execute <<-SQL
      ALTER TABLE "TB_ALTERACAO" DROP CONSTRAINT "FK_EVENTO_ALTERACAO";
      ALTER TABLE "TB_ALTERACAO" DROP CONSTRAINT "PK_TB_ALTERACAO";
    SQL

    drop_table :TB_ALTERACAO
  end
end
