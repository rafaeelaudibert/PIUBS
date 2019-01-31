# frozen_string_literal: true

class CreateEventType < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_TIPO_EVENTO, id: false do |t|
      t.bigint :CO_SEQ_ID
      t.string :NO_NOME, null: false
    end

    execute <<-SQL
      -- Sequence
      CREATE SEQUENCE "SQ_TIPO_EVENTO_ID";
      ALTER TABLE "TB_TIPO_EVENTO" ALTER COLUMN "CO_SEQ_ID" SET DEFAULT nextval('"SQ_TIPO_EVENTO_ID"');
      ALTER SEQUENCE "SQ_TIPO_EVENTO_ID" OWNED BY "TB_TIPO_EVENTO"."CO_SEQ_ID";

      -- PK
      ALTER TABLE "TB_TIPO_EVENTO" ADD CONSTRAINT "PK_TB_TIPO_EVENTO" PRIMARY KEY ("CO_SEQ_ID");
    SQL
  end

  def self.down
    drop_table :TB_TIPO_EVENTO
  end
end
