# frozen_string_literal: true

class CreateControversies < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_CONTROVERSIA, id: false do |t|
      t.bigint :CO_PROTOCOLO, null: false
      t.string :DS_TITULO, null: false
      t.string :DS_DESCRICAO, null: false
      t.integer :TP_STATUS, null: false, default: 0
      t.bigint :CO_SEI, null: false
      t.bigint :CO_CIDADE, null: false
      t.bigint :CO_CNES
      t.bigint :CO_USUARIO_EMPRESA
      t.bigint :CO_USUARIO_UNIDADE
      t.bigint :CO_USUARIO_CIDADE
      t.bigint :CO_CRIADO_POR, null: false
      t.bigint :CO_CATEGORIA, null: false
      t.integer :NU_COMPLEXIDADE, null: false, default: 1
      t.bigint :CO_SUPORTE
      t.bigint :CO_SUPORTE_ADICIONAL
      t.datetime :DT_CRIADO_EM
      t.datetime :DT_FINALIZADO_EM
    end

    execute 'ALTER TABLE "TB_CONTROVERSIA" ADD CONSTRAINT "PK_TB_CONTROVERSIA" PRIMARY KEY ("CO_PROTOCOLO");'
    add_foreign_key :TB_CONTROVERSIA, :TB_EMPRESA, column: :CO_SEI, primary_key: :CO_SEI, name: 'FK_EMPRESA_CONTROVERSIA'
    add_foreign_key :TB_CONTROVERSIA, :TB_CIDADE, column: :CO_CIDADE, primary_key: :CO_CODIGO, name: 'FK_CIDADE_CONTROVERSIA'
    add_foreign_key :TB_CONTROVERSIA, :TB_UBS, column: :CO_CNES, primary_key: :CO_CNES, name: 'FK_UBS_CONTROVERSIA'
    add_foreign_key :TB_CONTROVERSIA, :TB_CATEGORIA, column: :CO_CATEGORIA, primary_key: :CO_SEQ_ID, name: 'FK_CATEGORIA_CONTROVERSIA'
    add_foreign_key :TB_CONTROVERSIA, :TB_USUARIO, column: :CO_USUARIO_EMPRESA, name: 'FK_USUARIO_CONTROVERSIAUSUARIOEMPRESA'
    add_foreign_key :TB_CONTROVERSIA, :TB_USUARIO, column: :CO_USUARIO_UNIDADE, name: 'FK_USUARIO_CONTROVERSIAUSUARIOUNIDADE'
    add_foreign_key :TB_CONTROVERSIA, :TB_USUARIO, column: :CO_USUARIO_CIDADE, name: 'FK_USUARIO_CONTROVERSIAUSUARIOCIDADE'
    add_foreign_key :TB_CONTROVERSIA, :TB_USUARIO, column: :CO_SUPORTE, name: 'FK_USUARIO_CONTROVERSIASUPORTE'
    add_foreign_key :TB_CONTROVERSIA, :TB_USUARIO, column: :CO_SUPORTE_ADICIONAL, name: 'FK_USUARIO_CONTROVERSIASUPORTEADICIONAL'
    add_index :TB_CONTROVERSIA, :CO_SEI, name: "IN_FKCONTROVERSIA_COSEI"
    add_index :TB_CONTROVERSIA, :CO_CIDADE, name: "IN_FKCONTROVERSIA_COCIDADE"
    add_index :TB_CONTROVERSIA, :CO_CNES, name: "IN_FKCONTROVERSIA_COCNES"
    add_index :TB_CONTROVERSIA, :CO_CATEGORIA, name: "IN_FKCONTROVERSIA_COCATEGORIA"
    add_index :TB_CONTROVERSIA, :CO_USUARIO_EMPRESA, name: "IN_FKCONTROVERSIA_COUSUARIOEMPRESA"
    add_index :TB_CONTROVERSIA, :CO_USUARIO_UNIDADE, name: "IN_FKCONTROVERSIA_COUSUARIOUNIDADE"
    add_index :TB_CONTROVERSIA, :CO_USUARIO_CIDADE, name: "IN_FKCONTROVERSIA_COUSUARIOCIDADE"
    add_index :TB_CONTROVERSIA, :CO_SUPORTE, name: "IN_FKCONTROVERSIA_COSUPORTE"
    add_index :TB_CONTROVERSIA, :CO_SUPORTE_ADICIONAL, name: "IN_FKCONTROVERSIA_COSUPORTEADICIONAL"
  end

  def self.down
    remove_index :TB_CONTROVERSIA, name: "IN_FKCONTROVERSIA_COSEI"
    remove_index :TB_CONTROVERSIA, name: "IN_FKCONTROVERSIA_COCIDADE"
    remove_index :TB_CONTROVERSIA, name: "IN_FKCONTROVERSIA_COCNES"
    remove_index :TB_CONTROVERSIA, name: "IN_FKCONTROVERSIA_COCATEGORIA"
    remove_index :TB_CONTROVERSIA, name: "IN_FKCONTROVERSIA_COUSUARIOEMPRESA"
    remove_index :TB_CONTROVERSIA, name: "IN_FKCONTROVERSIA_COUSUARIOUNIDADE"
    remove_index :TB_CONTROVERSIA, name: "IN_FKCONTROVERSIA_COUSUARIOCIDADE"
    remove_index :TB_CONTROVERSIA, name: "IN_FKCONTROVERSIA_COSUPORTE"
    remove_index :TB_CONTROVERSIA, name: "IN_FKCONTROVERSIA_COSUPORTEADICIONAL"
    remove_foreign_key :TB_CONTROVERSIA, name: 'FK_EMPRESA_CONTROVERSIA'
    remove_foreign_key :TB_CONTROVERSIA, name: 'FK_CIDADE_CONTROVERSIA'
    remove_foreign_key :TB_CONTROVERSIA, name: 'FK_UBS_CONTROVERSIA'
    remove_foreign_key :TB_CONTROVERSIA, name: 'FK_CATEGORIA_CONTROVERSIA'
    remove_foreign_key :TB_CONTROVERSIA, name: 'FK_USUARIO_CONTROVERSIAUSUARIOEMPRESA'
    remove_foreign_key :TB_CONTROVERSIA, name: 'FK_USUARIO_CONTROVERSIAUSUARIOUNIDADE'
    remove_foreign_key :TB_CONTROVERSIA, name: 'FK_USUARIO_CONTROVERSIAUSUARIOCIDADE'
    remove_foreign_key :TB_CONTROVERSIA, name: 'FK_USUARIO_CONTROVERSIASUPORTE'
    remove_foreign_key :TB_CONTROVERSIA, name: 'FK_USUARIO_CONTROVERSIASUPORTEADICIONAL'
    drop_table :TB_CONTROVERSIA
  end
end
