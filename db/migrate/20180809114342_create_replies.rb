# frozen_string_literal: true

class CreateReplies < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_RESPOSTA, id: false do |t|
      t.bigint :CO_ID
      t.string :DS_DESCRICAO, null: false
      t.string :ST_FAQ, limit: 1, null: false, default: 'N'
      t.datetime :DT_CRIADO_EM
    end

    execute 'ALTER TABLE "TB_RESPOSTA" ADD CONSTRAINT "PK_TB_RESPOSTA" PRIMARY KEY ("CO_ID");'
    add_foreign_key :TB_RESPOSTA, :TB_EVENTO, column: :CO_ID, primary_key: :CO_SEQ_ID, name: 'FK_EVENTO_RESPOSTA'
    add_index :TB_RESPOSTA, :CO_ID, name: "IN_FKRESPOSTA_COID"
  end

  def self.down
    remove_index :TB_RESPOSTA, name: "IN_FKRESPOSTA_COID"
    remove_foreign_key :TB_RESPOSTA, name: 'FK_EVENTO_RESPOSTA'
    drop_table :TB_RESPOSTA
  end
end
