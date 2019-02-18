# frozen_string_literal: true

class CreateUnities < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_UBS, id: false do |t|
      t.bigint :CO_CNES, null: false
      t.string :NO_NOME, null: false
      t.bigint :CO_CIDADE, null: false
      t.string :DS_ENDERECO, default: ''
      t.string :DS_BAIRRO, default: ''
      t.string :DS_TELEFONE, default: ''
    end

    execute 'ALTER TABLE "TB_UBS" ADD CONSTRAINT "PK_TB_UBS" PRIMARY KEY ("CO_CNES");'
    add_foreign_key :TB_UBS, :TB_CIDADE, column: :CO_CIDADE, primary_key: :CO_CODIGO, name: 'FK_CIDADE_UBS'
    add_index :TB_UBS, :CO_CIDADE, name: "IN_FKUBS_COCIDADE"
  end

  def self.down
    remove_index :TB_UBS, name: "IN_FKUBS_COCIDADE"
    remove_foreign_key :TB_UBS, name: 'FK_CIDADE_UBS'
    drop_table :TB_UBS
  end
end
