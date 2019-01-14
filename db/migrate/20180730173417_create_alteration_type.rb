# frozen_string_literal: true

class CreateAlterationType < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_TIPO_ALTERACAO, id: false do |t|
      t.bigint :CO_SEQ_ID
      t.string :NO_NOME, null: false
    end

    execute <<-SQL
      CREATE SEQUENCE "SQ_TIPO_ALTERACAO_ID";
      ALTER TABLE "TB_TIPO_ALTERACAO" ADD CONSTRAINT "PK_TB_TIPO_ALTERACAO" PRIMARY KEY ("CO_SEQ_ID");
      ALTER TABLE "TB_TIPO_ALTERACAO" ALTER COLUMN "CO_SEQ_ID" SET DEFAULT nextval('"SQ_TIPO_ALTERACAO_ID"');
      -- ALTER SEQUENCE TB_TIPO_ALTERACAO_CO_SEQ_ID_SEQ OWNED BY NONE;
      ALTER SEQUENCE "SQ_TIPO_ALTERACAO_ID" OWNED BY "TB_TIPO_ALTERACAO"."CO_SEQ_ID";
    SQL
  end

  def self.down
    execute 'ALTER TABLE "TB_TIPO_ALTERACAO" DROP CONSTRAINT "PK_TB_TIPO_ALTERACAO";'
    drop_table :TB_TIPO_ALTERACAO
  end
end
