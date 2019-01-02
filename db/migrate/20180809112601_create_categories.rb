# frozen_string_literal: true

class CreateCategories < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_CATEGORIA, id: false do |t|
      t.integer :CO_SEQ_ID
      t.string :NO_NOME, null: false
      t.integer :CO_CATEGORIA_PAI
      t.integer :NU_PROFUNDIDADE, default: 0
      t.integer :NU_SEVERIDADE, null: false
      t.integer :CO_SISTEMA_ORIGEM, null: false
    end

    execute <<-SQL
      CREATE SEQUENCE "SQ_CATEGORIA_ID";
      ALTER TABLE "TB_CATEGORIA" ADD CONSTRAINT "PK_TB_CATEGORIA" PRIMARY KEY ("CO_SEQ_ID");
      ALTER TABLE "TB_CATEGORIA" ALTER COLUMN "CO_SEQ_ID" SET DEFAULT nextval('"SQ_CATEGORIA_ID"');
      -- ALTER SEQUENCE TB_CATEGORIA_CO_SEQ_ID_SEQ OWNED BY NONE;
      ALTER SEQUENCE "SQ_CATEGORIA_ID" OWNED BY "TB_CATEGORIA"."CO_SEQ_ID";
    SQL

    add_foreign_key :TB_CATEGORIA, :TB_CATEGORIA, column: :CO_CATEGORIA_PAI, primary_key: :CO_SEQ_ID
  end

  def self.down
    execute 'ALTER TABLE "TB_CATEGORIA" DROP CONSTRAINT "PK_TB_CATEGORIA";'
    drop_table :TB_CATEGORIA
  end
end
