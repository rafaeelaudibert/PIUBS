# frozen_string_literal: true

class CreateReplies < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_RESPOSTA, id: false do |t|
      t.bigint :CO_ID
      t.string :DS_DESCRICAO, null: false
      t.string :ST_FAQ, limit: 1, null: false, default: 'N'
      t.datetime :DT_CRIADO_EM
    end

    add_foreign_key :TB_RESPOSTA, :TB_EVENTO, column: :CO_ID, primary_key: :CO_SEQ_ID

    execute 'ALTER TABLE "TB_RESPOSTA" ADD CONSTRAINT "PK_TB_RESPOSTA" PRIMARY KEY ("CO_ID");'
  end

  def self.down
    execute 'ALTER TABLE "TB_RESPOSTA" DROP CONSTRAINT "PK_TB_RESPOSTA";'
    drop_table :TB_RESPOSTA
  end
end
