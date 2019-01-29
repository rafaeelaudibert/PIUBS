# frozen_string_literal: true

class CreateSystems < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_SISTEMA, id: false do |t|
      t.bigint :CO_SEQ_ID
      t.string :NO_NOME, null: false
    end

    execute <<-SQL
      CREATE SEQUENCE "SQ_SISTEMA_ID";
      
      ALTER TABLE "TB_SISTEMA" ADD CONSTRAINT "PK_TB_SISTEMA" PRIMARY KEY ("CO_SEQ_ID");

      ALTER TABLE "TB_SISTEMA" ALTER COLUMN "CO_SEQ_ID" SET DEFAULT nextval('"SQ_SISTEMA_ID"');

      ALTER SEQUENCE "SQ_SISTEMA_ID" OWNED BY "TB_SISTEMA"."CO_SEQ_ID";
    SQL
  end

  def self.down
    execute <<-SQL
      ALTER TABLE "TB_SISTEMA" DROP CONSTRAINT "PK_TB_SISTEMA";
    SQL
    drop_table :TB_SISTEMA
  end
end
