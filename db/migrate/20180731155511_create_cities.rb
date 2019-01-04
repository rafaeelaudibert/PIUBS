# frozen_string_literal: true

class CreateCities < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_CIDADE, id: false do |t|
      t.bigint :CO_CODIGO, null: false
      t.string :NO_NOME, null: false
      t.bigint :CO_UF, null: false
    end

    add_foreign_key :TB_CIDADE, :TB_UF, column: :CO_UF, primary_key: :CO_CODIGO

    execute 'ALTER TABLE "TB_CIDADE" ADD CONSTRAINT "PK_TB_CIDADE" PRIMARY KEY ("CO_CODIGO");'
  end

  def self.down
    execute 'ALTER TABLE "TB_CIDADE" DROP CONSTRAINT "PK_TB_CIDADE";'
    drop_table :TB_UF
  end
end
