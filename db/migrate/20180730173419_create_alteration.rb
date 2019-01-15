# frozen_string_literal: true

class CreateAlteration < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_ALTERACAO, id: false do |t|
      t.bigint :CO_ID
      t.bigint :CO_TIPO
    end

    add_foreign_key :TB_ALTERACAO, :TB_EVENTO, column: :CO_ID, primary_key: :CO_SEQ_ID

    execute 'ALTER TABLE "TB_ALTERACAO" ADD CONSTRAINT "PK_TB_ALTERACAO" PRIMARY KEY ("CO_ID");'
  end

  def self.down
    execute 'ALTER TABLE "TB_ALTERACAO" DROP CONSTRAINT "PK_TB_ALTERACAO";'
    drop_table :TB_EVENTO
  end
end
