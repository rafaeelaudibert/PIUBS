# frozen_string_literal: true

class CreateEventType < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_TIPO_EVENTO, id: false do |t|
      t.bigint :CO_SEQ_ID
      t.string :NO_NOME, null: false
    end

    execute <<-SQL
      CREATE SEQUENCE "SQ_TIPO_EVENTO_ID";
      
      ALTER TABLE "TB_TIPO_EVENTO" ADD CONSTRAINT "PK_TB_TIPO_EVENTO" PRIMARY KEY ("CO_SEQ_ID");

      ALTER TABLE "TB_TIPO_EVENTO" ALTER COLUMN "CO_SEQ_ID" SET DEFAULT nextval('"SQ_TIPO_EVENTO_ID"');

      ALTER SEQUENCE "SQ_TIPO_EVENTO_ID" OWNED BY "TB_TIPO_EVENTO"."CO_SEQ_ID";
    SQL
  end

  def self.down
    execute <<-SQL
      ALTER TABLE "TB_TIPO_EVENTO" DROP CONSTRAINT "PK_TB_TIPO_EVENTO";
    SQL
    drop_table :TIPO_EVENTO
  end
end
