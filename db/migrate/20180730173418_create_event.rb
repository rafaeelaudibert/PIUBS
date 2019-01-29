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

      ALTER SEQUENCE "SQ_ALTERACAO_ID" OWNED BY "TB_EVENTO"."CO_SEQ_ID";
      
      ALTER TABLE "TB_EVENTO" ADD CONSTRAINT "FK_SISTEMA_EVENTO" FOREIGN KEY ("CO_SISTEMA_ORIGEM")
        REFERENCES "TB_SISTEMA" ("CO_SEQ_ID") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;
      
      ALTER TABLE "TB_EVENTO" ADD CONSTRAINT "FK_USUARIO_EVENTO" FOREIGN KEY ("CO_USUARIO")
        REFERENCES "TB_USUARIO" ("id") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;
      
      ALTER TABLE "TB_EVENTO" ADD CONSTRAINT "FK_TIPO_EVENTO_EVENTO" FOREIGN KEY ("CO_TIPO")
        REFERENCES "TB_TIPO_EVENTO" ("CO_SEQ_ID") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;
    SQL
  end

  def self.down
    execute <<-SQL
      ALTER TABLE "TB_EVENTO" DROP CONSTRAINT "PK_TB_EVENTO";
      ALTER TABLE "TB_EVENTO" DROP CONSTRAINT "FK_SISTEMA_EVENTO";
      ALTER TABLE "TB_EVENTO" DROP CONSTRAINT "FK_USUARIO_EVENTO";
      ALTER TABLE "TB_EVENTO" DROP CONSTRAINT "FK_TIPO_EVENTO_EVENTO";
    SQL
    drop_table :TB_EVENTO
  end
end
