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
      -- Sequence
      CREATE SEQUENCE "SQ_ALTERACAO_ID";
      ALTER TABLE "TB_EVENTO" ALTER COLUMN "CO_SEQ_ID" SET DEFAULT nextval('"SQ_ALTERACAO_ID"');
      ALTER SEQUENCE "SQ_ALTERACAO_ID" OWNED BY "TB_EVENTO"."CO_SEQ_ID";

      -- PK
      ALTER TABLE "TB_EVENTO" ADD CONSTRAINT "PK_TB_EVENTO" PRIMARY KEY ("CO_SEQ_ID");
    SQL

    add_foreign_key :TB_EVENTO, :TB_SISTEMA, column: :CO_SISTEMA_ORIGEM, primary_key: :CO_SEQ_ID, name: 'FK_SISTEMA_EVENTO'
    add_foreign_key :TB_EVENTO, :TB_TIPO_EVENTO, column: :CO_TIPO, primary_key: :CO_SEQ_ID, name: 'FK_TIPO_EVENTO_EVENTO'
    add_foreign_key :TB_EVENTO, :TB_USUARIO, column: :CO_USUARIO, primary_key: :id, name: 'FK_USUARIO_EVENTO'
    add_index :TB_EVENTO, :CO_SISTEMA_ORIGEM, name: 'IN_FKEVENTO_COSISTEMAORIGEM'
    add_index :TB_EVENTO, :CO_USUARIO, name: 'IN_FKEVENTO_COUSUARIO'
    add_index :TB_EVENTO, :CO_TIPO, name: 'IN_FKEVENTO_COTIPO'
  end

  def self.down
    remove_index :TB_EVENTO, name: 'IN_FKEVENTO_COSISTEMAORIGEM'
    remove_index :TB_EVENTO, name: 'IN_FKEVENTO_COUSUARIO'
    remove_index :TB_EVENTO, name: 'IN_FKEVENTO_COTIPO'
    remove_foreign_key :TB_EVENTO, name: 'FK_SISTEMA_EVENTO'
    remove_foreign_key :TB_EVENTO, name: 'FK_TIPO_EVENTO_EVENTO'
    remove_foreign_key :TB_EVENTO, name: 'FK_USUARIO_EVENTO'
    drop_table :TB_EVENTO
  end
end
