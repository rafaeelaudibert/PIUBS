# frozen_string_literal: true

class CreateAttachmentsLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :RT_LINK_ANEXO, id: false do |t|
      t.uuid :CO_ID, null: false, default: 'uuid_generate_v4()'
      t.uuid :CO_ANEXO, null: false
      t.bigint :CO_RESPOSTA
      t.bigint :CO_ATENDIMENTO
      t.bigint :CO_QUESTAO
      t.bigint :CO_CONTROVERSIA
      t.bigint :CO_FEEDBACK
      t.bigint :TP_ENTIDADE_ORIGEM, null: false
      t.datetime :DT_CRIADO_EM
    end

    add_foreign_key :RT_LINK_ANEXO, :TB_ANEXO, column: :CO_ANEXO, primary_key: :CO_ID
    add_foreign_key :RT_LINK_ANEXO, :TB_RESPOSTA, column: :CO_RESPOSTA, primary_key: :CO_ID
    add_foreign_key :RT_LINK_ANEXO, :TB_ATENDIMENTO, column: :CO_ATENDIMENTO, primary_key: :CO_PROTOCOLO
    add_foreign_key :RT_LINK_ANEXO, :TB_QUESTAO, column: :CO_QUESTAO, primary_key: :CO_SEQ_ID
    add_foreign_key :RT_LINK_ANEXO, :TB_CONTROVERSIA, column: :CO_CONTROVERSIA, primary_key: :CO_PROTOCOLO
    add_foreign_key :RT_LINK_ANEXO, :TB_FEEDBACK, column: :CO_FEEDBACK, primary_key: :CO_PROTOCOLO
  end
end
