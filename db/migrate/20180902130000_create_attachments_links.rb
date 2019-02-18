# frozen_string_literal: true

class CreateAttachmentsLinks < ActiveRecord::Migration[5.2]
  def self.up
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

    add_foreign_key :RT_LINK_ANEXO, :TB_ANEXO, column: :CO_ANEXO, primary_key: :CO_ID, name: 'FK_ANEXO_LINK_ANEXO'
    add_foreign_key :RT_LINK_ANEXO, :TB_RESPOSTA, column: :CO_RESPOSTA, primary_key: :CO_ID, name: 'FK_RESPOSTA_LINK_ANEXO'
    add_foreign_key :RT_LINK_ANEXO, :TB_ATENDIMENTO, column: :CO_ATENDIMENTO, primary_key: :CO_PROTOCOLO, name: 'FK_ATENDIMENTO_LINK_ANEXO'
    add_foreign_key :RT_LINK_ANEXO, :TB_QUESTAO, column: :CO_QUESTAO, primary_key: :CO_SEQ_ID, name: 'FK_QUESTAO_LINK_ANEXO'
    add_foreign_key :RT_LINK_ANEXO, :TB_CONTROVERSIA, column: :CO_CONTROVERSIA, primary_key: :CO_PROTOCOLO, name: 'FK_CONTROVERSIA_LINK_ANEXO'
    add_foreign_key :RT_LINK_ANEXO, :TB_FEEDBACK, column: :CO_FEEDBACK, primary_key: :CO_PROTOCOLO, name: 'FK_FEEDBACK_LINK_ANEXO'
    add_index :RT_LINK_ANEXO, :CO_ANEXO, name: "IN_FKLINKANEXO_COANEXO"
    add_index :RT_LINK_ANEXO, :CO_RESPOSTA, name: "IN_FKLINKANEXO_CORESPOSTA"
    add_index :RT_LINK_ANEXO, :CO_ATENDIMENTO, name: "IN_FKLINKANEXO_COATENDIMENTO"
    add_index :RT_LINK_ANEXO, :CO_QUESTAO, name: "IN_FKLINKANEXO_COQUESTAO"
    add_index :RT_LINK_ANEXO, :CO_CONTROVERSIA, name: "IN_FKLINKANEXO_COCONTROVERSIA"
    add_index :RT_LINK_ANEXO, :CO_FEEDBACK, name: "IN_FKLINKANEXO_COFEEDBACK"
  end

  def self.down
    remove_index :RT_LINK_ANEXO, name: "IN_FKLINKANEXO_COANEXO"
    remove_index :RT_LINK_ANEXO, name: "IN_FKLINKANEXO_CORESPOSTA"
    remove_index :RT_LINK_ANEXO, name: "IN_FKLINKANEXO_COATENDIMENTO"
    remove_index :RT_LINK_ANEXO, name: "IN_FKLINKANEXO_COQUESTAO"
    remove_index :RT_LINK_ANEXO, name: "IN_FKLINKANEXO_COCONTROVERSIA"
    remove_index :RT_LINK_ANEXO, name: "IN_FKLINKANEXO_COFEEDBACK"
    remove_foreign_key :RT_LINK_ANEXO, name: 'FK_ANEXO_LINK_ANEXO'
    remove_foreign_key :RT_LINK_ANEXO, name: 'FK_RESPOSTA_LINK_ANEXO'
    remove_foreign_key :RT_LINK_ANEXO, name: 'FK_ATENDIMENTO_LINK_ANEXO'
    remove_foreign_key :RT_LINK_ANEXO, name: 'FK_QUESTAO_LINK_ANEXO'
    remove_foreign_key :RT_LINK_ANEXO, name: 'FK_CONTROVERSIA_LINK_ANEXO'
    remove_foreign_key :RT_LINK_ANEXO, name: 'FK_FEEDBACK_LINK_ANEXO'
    drop_table :RT_LINK_ANEXO
  end
end
