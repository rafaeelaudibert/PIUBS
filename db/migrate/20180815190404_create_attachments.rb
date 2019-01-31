# frozen_string_literal: true

class CreateAttachments < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_ANEXO, id: false do |t|
      t.uuid :CO_ID, null: false, default: 'uuid_generate_v4()'
      t.string :NO_NOME_ANEXO, null: false
      t.string :DS_TIPO_ANEXO, null: false
      t.binary :BL_CONTEUDO, null: false, limit: 35.megabytes
      t.datetime :DT_CRIADO_EM, null: false
    end

    execute 'ALTER TABLE "TB_ANEXO" ADD CONSTRAINT "PK_TB_ANEXO" PRIMARY KEY ("CO_ID");'
  end

  def self.down
    drop_table :TB_ANEXO
  end
end
