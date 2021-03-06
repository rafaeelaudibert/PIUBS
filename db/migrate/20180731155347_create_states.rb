# frozen_string_literal: true

class CreateStates < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_UF, id: false do |t|
      t.bigint :CO_CODIGO, null: false
      t.string :NO_NOME, null: false
      t.string :SG_SIGLA, null: false, limit: 2
    end

    execute 'ALTER TABLE "TB_UF" ADD CONSTRAINT "PK_TB_UF" PRIMARY KEY ("CO_CODIGO");'
  end

  def self.down
    drop_table :TB_UF
  end
end
