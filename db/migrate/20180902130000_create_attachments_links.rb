# frozen_string_literal: true

class CreateAttachmentsLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :RT_LINK_ANEXO, id: false do |t|
      t.uuid :CO_ID, null: false, default: 'uuid_generate_v4()'
      t.uuid :CO_ANEXO, null: false
      t.integer :CO_RESPOSTA
      t.integer :CO_ATENDIMENTO
      t.integer :CO_QUESTAO
      t.integer :TP_ENTIDADE_ORIGEM, null: false
      t.datetime :DT_CRIADO_EM
    end

    add_foreign_key :RT_LINK_ANEXO, :TB_ANEXO, column: :CO_ANEXO, primary_key: :CO_ID
    add_foreign_key :RT_LINK_ANEXO, :replies, column: :CO_RESPOSTA
    add_foreign_key :RT_LINK_ANEXO, :calls, column: :CO_ATENDIMENTO
    add_foreign_key :RT_LINK_ANEXO, :answers, column: :CO_QUESTAO
  end
end
