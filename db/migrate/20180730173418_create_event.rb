# frozen_string_literal: true

class CreateEvent < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_EVENTO, id: false do |t|
      t.bigint :CO_SEQ_ID
      t.datetime :DT_CRIADO_EM
      t.bigint :CO_TIPO
      t.bigint :CO_USUARIO
      t.bigint :CO_SISTEMA_ORIGEM
      t.bigint :CO_PROTOCOLO
    end

    execute <<-SQL
      CREATE SEQUENCE "SQ_ALTERACAO_ID";
      ALTER TABLE "TB_EVENTO" ADD CONSTRAINT "PK_TB_EVENTO" PRIMARY KEY ("CO_SEQ_ID");
      ALTER TABLE "TB_EVENTO" ALTER COLUMN "CO_SEQ_ID" SET DEFAULT nextval('"SQ_ALTERACAO_ID"');
      -- ALTER SEQUENCE TB_EVENTO_CO_SEQ_ID_SEQ OWNED BY NONE;
      ALTER SEQUENCE "SQ_ALTERACAO_ID" OWNED BY "TB_EVENTO"."CO_SEQ_ID";
    SQL

    add_foreign_key :TB_EVENTO, :TB_SISTEMA, column: :CO_SISTEMA_ORIGEM, primary_key: :CO_SEQ_ID
    add_foreign_key :TB_EVENTO, :TB_TIPO_EVENTO, column: :CO_TIPO, primary_key: :CO_SEQ_ID
    add_foreign_key :TB_EVENTO, :TB_USUARIO, column: :CO_USUARIO
  end

  def self.down
    execute 'ALTER TABLE "TB_EVENTO" DROP CONSTRAINT "PK_TB_EVENTO";'
    drop_table :TB_EVENTO
  end
end
