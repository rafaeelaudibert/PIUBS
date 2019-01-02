# frozen_string_literal: true

class CreateUnities < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_UBS, id: false do |t|
      t.integer :CO_CNES, null: false
      t.string :NO_NOME, null: false
      t.integer :CO_CIDADE, null: false
      t.string :DS_ENDERECO
      t.string :DS_BAIRRO
      t.string :DS_TELEFONE
    end

    add_foreign_key :TB_UBS, :TB_CIDADE, column: :CO_CIDADE, primary_key: :CO_CODIGO

    execute 'ALTER TABLE "TB_UBS" ADD CONSTRAINT "PK_TB_UBS" PRIMARY KEY ("CO_CNES");'
  end

  def self.down
    execute 'ALTER TABLE "TB_UBS" DROP CONSTRAINT "PK_TB_UBS";'
    drop_table :TB_UBS
  end
end
