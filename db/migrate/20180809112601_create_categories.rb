# frozen_string_literal: true

class CreateCategories < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_CATEGORIA, id: false do |t|
      t.bigint :CO_SEQ_ID
      t.string :NO_NOME, null: false
      t.bigint :CO_CATEGORIA_PAI
      t.integer :NU_PROFUNDIDADE, default: 0
      t.integer :NU_SEVERIDADE, null: false
      t.bigint :CO_SISTEMA_ORIGEM, null: false
    end

    execute <<-SQL
      -- Sequence
      CREATE SEQUENCE "SQ_CATEGORIA_ID";
      ALTER TABLE "TB_CATEGORIA" ALTER COLUMN "CO_SEQ_ID" SET DEFAULT nextval('"SQ_CATEGORIA_ID"');
      ALTER SEQUENCE "SQ_CATEGORIA_ID" OWNED BY "TB_CATEGORIA"."CO_SEQ_ID";

      -- PK
      ALTER TABLE "TB_CATEGORIA" ADD CONSTRAINT "PK_TB_CATEGORIA" PRIMARY KEY ("CO_SEQ_ID");
    SQL

    add_foreign_key :TB_CATEGORIA, :TB_CATEGORIA, column: :CO_CATEGORIA_PAI, primary_key: :CO_SEQ_ID, name: 'FK_CATEGORIA_CATEGORIA'
    add_foreign_key :TB_CATEGORIA, :TB_SISTEMA, column: :CO_SISTEMA_ORIGEM, primary_key: :CO_SEQ_ID, name: 'FK_SISTEMA_CATEGORIA'
    add_index :TB_CATEGORIA, :CO_CATEGORIA_PAI, name: "IN_FKCATEGORIA_COCATEGORIAPAI"
    add_index :TB_CATEGORIA, :CO_SISTEMA_ORIGEM, name: "IN_FKCATEGORIA_COSISTEMAORIGEM"
  end

  def self.down
    remove_index :TB_CATEGORIA, name: "IN_FKCATEGORIA_COCATEGORIAPAI"
    remove_index :TB_CATEGORIA, name: "IN_FKCATEGORIA_COSISTEMAORIGEM"
    remove_foreign_key :TB_CATEGORIA, name: 'FK_CATEGORIA_CATEGORIA'
    remove_foreign_key :TB_CATEGORIA, name: 'FK_SISTEMA_CATEGORIA'
    drop_table :TB_CATEGORIA
  end
end
