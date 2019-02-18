# frozen_string_literal: true

class CreateAlteration < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_ALTERACAO, id: false do |t|
      t.bigint :CO_ID
      t.bigint :CO_TIPO
    end

    execute 'ALTER TABLE "TB_ALTERACAO" ADD CONSTRAINT "PK_TB_ALTERACAO" PRIMARY KEY ("CO_ID");'
    add_foreign_key :TB_ALTERACAO, :TB_EVENTO, column: :CO_ID, primary_key: :CO_SEQ_ID, name: 'FK_EVENTO_ALTERACAO'
    add_index :TB_ALTERACAO, :CO_ID, name: "IN_FKALTERACAO_COID"
  end

  def self.down
    drop_table :TB_ALTERACAO
  end
end
