# frozen_string_literal: true

class CreateCalls < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_ATENDIMENTO, id: false do |t|
      t.bigint :CO_PROTOCOLO, null: false
      t.string :DS_TITULO, null: false
      t.text :DS_DESCRICAO, null: false
      t.integer :TP_STATUS, null: false, default: 0 # Open!
      t.string :DS_VERSAO_SISTEMA
      t.string :DS_PERFIL_ACESSO
      t.string :DS_DETALHE_FUNCIONALIDADE
      t.string :DS_SUMARIO_RESPOSTA
      t.bigint :CO_CIDADE, null: false
      t.integer :CO_CATEGORIA, null: false
      t.bigint :CO_UF, null: false
      t.bigint :CO_SEI, null: false
      t.datetime :DT_CRIADO_EM
      t.bigint :CO_USUARIO_EMPRESA, null: false
      t.bigint :CO_RESPOSTA
      t.bigint :CO_CNES
      t.bigint :CO_USUARIO_SUPORTE
      t.integer :NU_SEVERIDADE, default: 1 # Severidade normal
      t.datetime :DT_FINALIZADO_EM
      t.datetime :DT_REABERTO_EM
    end

    add_foreign_key :TB_ATENDIMENTO, :users, column: :CO_USUARIO_SUPORTE
    add_foreign_key :TB_ATENDIMENTO, :users, column: :CO_USUARIO_EMPRESA
    add_foreign_key :TB_ATENDIMENTO, :TB_UBS, column: :CO_CNES, primary_key: :CO_CNES
    add_foreign_key :TB_ATENDIMENTO, :TB_QUESTAO, column: :CO_RESPOSTA, primary_key: :CO_SEQ_ID
    add_foreign_key :TB_ATENDIMENTO, :TB_EMPRESA, column: :CO_SEI, primary_key: :CO_SEI
    add_foreign_key :TB_ATENDIMENTO, :TB_UF, column: :CO_UF, primary_key: :CO_CODIGO
    add_foreign_key :TB_ATENDIMENTO, :TB_CIDADE, column: :CO_CIDADE, primary_key: :CO_CODIGO
    add_foreign_key :TB_ATENDIMENTO, :TB_CATEGORIA, column: :CO_CATEGORIA, primary_key: :CO_SEQ_ID

    execute 'ALTER TABLE "TB_ATENDIMENTO" ADD CONSTRAINT "PK_TB_ATENDIMENTO" PRIMARY KEY ("CO_PROTOCOLO");'
  end

  def self.down
    execute 'ALTER TABLE "TB_ATENDIMENTO" DROP CONSTRAINT "PK_TB_ATENDIMENTO";'
    drop_table :TB_ATENDIMENTO
  end
end
