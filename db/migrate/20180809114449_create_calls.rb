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
      t.bigint :CO_CIDADE, null: false
      t.integer :CO_CATEGORIA, null: false
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

    execute 'ALTER TABLE "TB_ATENDIMENTO" ADD CONSTRAINT "PK_TB_ATENDIMENTO" PRIMARY KEY ("CO_PROTOCOLO");'
    add_foreign_key :TB_ATENDIMENTO, :TB_USUARIO, column: :CO_USUARIO_SUPORTE, name: 'FK_USUARIO_ATENDIMENTOUSUARIOSUPORTE'
    add_foreign_key :TB_ATENDIMENTO, :TB_USUARIO, column: :CO_USUARIO_EMPRESA, name: 'FK_USUARIO_ATENDIMENTOUSUARIOEMPRESA'
    add_foreign_key :TB_ATENDIMENTO, :TB_UBS, column: :CO_CNES, primary_key: :CO_CNES, name: 'FK_UBS_ATENDIMENTO'
    add_foreign_key :TB_ATENDIMENTO, :TB_QUESTAO, column: :CO_RESPOSTA, primary_key: :CO_SEQ_ID, name: 'FK_QUESTAO_ATENDIMENTO'
    add_foreign_key :TB_ATENDIMENTO, :TB_EMPRESA, column: :CO_SEI, primary_key: :CO_SEI, name: 'FK_EMPRESA_ATENDIMENTO'
    add_foreign_key :TB_ATENDIMENTO, :TB_CIDADE, column: :CO_CIDADE, primary_key: :CO_CODIGO, name: 'FK_CIDADE_ATENDIMENTO'
    add_foreign_key :TB_ATENDIMENTO, :TB_CATEGORIA, column: :CO_CATEGORIA, primary_key: :CO_SEQ_ID, name: 'FK_CATEGORIA_ATENDIMENTO'
    add_index :TB_ATENDIMENTO, :CO_USUARIO_SUPORTE, name: "IN_FKATENDIMENTO_COUSUARIOSUPORTE"
    add_index :TB_ATENDIMENTO, :CO_USUARIO_EMPRESA, name: "IN_FKATENDIMENTO_COUSUARIOEMPRESA"
    add_index :TB_ATENDIMENTO, :CO_CNES, name: "IN_FKATENDIMENTO_COCNES"
    add_index :TB_ATENDIMENTO, :CO_RESPOSTA, name: "IN_FKATENDIMENTO_CORESPOSTA"
    add_index :TB_ATENDIMENTO, :CO_SEI, name: "IN_FKATENDIMENTO_COSEI"
    add_index :TB_ATENDIMENTO, :CO_CIDADE, name: "IN_FKATENDIMENTO_COCIDADE"
    add_index :TB_ATENDIMENTO, :CO_CATEGORIA, name: "IN_FKATENDIMENTO_COCATEGORIA"
  end

  def self.down
    remove_index :TB_ATENDIMENTO, name: "IN_FKATENDIMENTO_COUSUARIOSUPORTE"
    remove_index :TB_ATENDIMENTO, name: "IN_FKATENDIMENTO_COUSUARIOEMPRESA"
    remove_index :TB_ATENDIMENTO, name: "IN_FKATENDIMENTO_COCNES"
    remove_index :TB_ATENDIMENTO, name: "IN_FKATENDIMENTO_CORESPOSTA"
    remove_index :TB_ATENDIMENTO, name: "IN_FKATENDIMENTO_COSEI"
    remove_index :TB_ATENDIMENTO, name: "IN_FKATENDIMENTO_COCIDADE"
    remove_index :TB_ATENDIMENTO, name: "IN_FKATENDIMENTO_COCATEGORIA"
    remove_foreign_key :TB_ATENDIMENTO, name: 'FK_USUARIO_ATENDIMENTOUSUARIOSUPORTE'
    remove_foreign_key :TB_ATENDIMENTO, name: 'FK_USUARIO_ATENDIMENTOUSUARIOEMPRESA'
    remove_foreign_key :TB_ATENDIMENTO, name: 'FK_UBS_ATENDIMENTO'
    remove_foreign_key :TB_ATENDIMENTO, name: 'FK_QUESTAO_ATENDIMENTO'
    remove_foreign_key :TB_ATENDIMENTO, name: 'FK_EMPRESA_ATENDIMENTO'
    remove_foreign_key :TB_ATENDIMENTO, name: 'FK_CIDADE_ATENDIMENTO'
    remove_foreign_key :TB_ATENDIMENTO, name: 'FK_CATEGORIA_ATENDIMENTO'
    drop_table :TB_ATENDIMENTO
  end
end
