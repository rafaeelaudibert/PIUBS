# frozen_string_literal: true

class CreateAnswers < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_QUESTAO, id: false do |t|
      t.bigint :CO_SEQ_ID, null: false
      t.text :DS_QUESTAO, null: false
      t.text :DS_RESPOSTA, null: false
      t.bigint :CO_CATEGORIA, null: false
      t.bigint :CO_USUARIO, null: false
      t.string :ST_FAQ, limit: 1, null: false, default: 'N'
      t.string :DS_PALAVRA_CHAVE, null: false
      t.bigint :CO_SISTEMA_ORIGEM, null: false
      t.datetime :DT_CRIADO_EM
    end

    execute <<-SQL
      -- Sequence
      CREATE SEQUENCE "SQ_QUESTAO_ID";
      ALTER TABLE "TB_QUESTAO" ALTER COLUMN "CO_SEQ_ID" SET DEFAULT nextval('"SQ_QUESTAO_ID"');
      ALTER SEQUENCE "SQ_QUESTAO_ID" OWNED BY "TB_QUESTAO"."CO_SEQ_ID";

      -- PK
      ALTER TABLE "TB_QUESTAO" ADD CONSTRAINT "PK_TB_QUESTAO" PRIMARY KEY ("CO_SEQ_ID");
    SQL

    add_foreign_key :TB_QUESTAO, :TB_SISTEMA, column: :CO_SISTEMA_ORIGEM, primary_key: :CO_SEQ_ID, name: 'FK_SISTEMA_QUESTAO'
    add_foreign_key :TB_QUESTAO, :TB_CATEGORIA, column: :CO_CATEGORIA, primary_key: :CO_SEQ_ID, name: 'FK_CATEGORIA_QUESTAO'
    add_foreign_key :TB_QUESTAO, :TB_USUARIO, column: :CO_USUARIO, name: 'FK_USUARIO_QUESTAO'
    add_index :TB_QUESTAO, :CO_SISTEMA_ORIGEM, name: "IN_FKQUESTAO_COSISTEMAORIGEM"
    add_index :TB_QUESTAO, :CO_CATEGORIA, name: "IN_FKQUESTAO_COCATEGORIA"
    add_index :TB_QUESTAO, :CO_USUARIO, name: "IN_FKQUESTAO_COUSUARIO"
  end

  def self.down
    remove_index :TB_QUESTAO, name: "IN_FKQUESTAO_COSISTEMAORIGEM"
    remove_index :TB_QUESTAO, name: "IN_FKQUESTAO_COCATEGORIA"
    remove_index :TB_QUESTAO, name: "IN_FKQUESTAO_COUSUARIO"
    remove_foreign_key :TB_QUESTAO, name: 'FK_SISTEMA_QUESTAO'
    remove_foreign_key :TB_QUESTAO, name: 'FK_CATEGORIA_QUESTAO'
    remove_foreign_key :TB_QUESTAO, name: 'FK_USUARIO_QUESTAO'
    drop_table :TB_QUESTAO
  end
end
