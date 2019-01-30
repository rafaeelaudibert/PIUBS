# frozen_string_literal: true

class CreateCities < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_CIDADE, id: false do |t|
      t.bigint :CO_CODIGO, null: false
      t.string :NO_NOME, null: false
      t.bigint :CO_UF, null: false
    end

    execute <<-SQL
      -- PK
      ALTER TABLE "TB_CIDADE" ADD CONSTRAINT "PK_TB_CIDADE" PRIMARY KEY ("CO_CODIGO");

      -- FK
      ALTER TABLE "TB_CIDADE" ADD CONSTRAINT "FK_UF_CIDADE" FOREIGN KEY ("CO_UF")
        REFERENCES "TB_UF" ("CO_CODIGO") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;
    SQL
  end

  def self.down
    execute <<-SQL
      ALTER TABLE "TB_CIDADE" DROP CONSTRAINT "FK_UF_CIDADE";
      ALTER TABLE "TB_CIDADE" DROP CONSTRAINT "PK_TB_CIDADE";
    SQL

    drop_table :TB_CIDADE
  end
end
