# frozen_string_literal: true

class CreateCities < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_CIDADE, id: false do |t|
      t.bigint :CO_CODIGO, null: false
      t.string :NO_NOME, null: false
      t.bigint :CO_UF, null: false
    end

    execute 'ALTER TABLE "TB_CIDADE" ADD CONSTRAINT "PK_TB_CIDADE" PRIMARY KEY ("CO_CODIGO");'
    add_foreign_key :TB_CIDADE, :TB_UF, column: :CO_UF, primary_key: :CO_CODIGO, name: 'FK_UF_CIDADE'
    add_index :TB_CIDADE, :CO_UF, name: "IN_FKCIDADE_COUF"
  end

  def self.down
    remove_index :TB_CIDADE, name: "IN_FKCIDADE_COUF"
    remove_foreign_key :TB_CIDADE, name: 'FK_UF_CIDADE'
    drop_table :TB_CIDADE
  end
end
