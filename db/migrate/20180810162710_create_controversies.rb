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

    add_foreign_key :TB_CONTROVERSIA, :TB_EMPRESA, column: :CO_SEI, primary_key: :CO_SEI
    add_foreign_key :TB_CONTROVERSIA, :TB_CIDADE, column: :CO_CIDADE, primary_key: :CO_CODIGO
    add_foreign_key :TB_CONTROVERSIA, :TB_UBS, column: :CO_CNES, primary_key: :CO_CNES
    add_foreign_key :TB_CONTROVERSIA, :TB_CATEGORIA, column: :CO_CATEGORIA, primary_key: :CO_SEQ_ID
    add_foreign_key :TB_CONTROVERSIA, :users, column: :CO_USUARIO_EMPRESA
    add_foreign_key :TB_CONTROVERSIA, :users, column: :CO_USUARIO_UNIDADE
    add_foreign_key :TB_CONTROVERSIA, :users, column: :CO_USUARIO_CIDADE
    add_foreign_key :TB_CONTROVERSIA, :users, column: :CO_SUPORTE
    add_foreign_key :TB_CONTROVERSIA, :users, column: :CO_SUPORTE_ADICIONAL
    execute 'ALTER TABLE "TB_CONTROVERSIA" ADD CONSTRAINT "PK_TB_CONTROVERSIA" PRIMARY KEY ("CO_PROTOCOLO");'
  end

  def self.down
    execute 'ALTER TABLE "TB_CONTROVERSIA" DROP CONSTRAINT "PK_TB_CONTROVERSIA";'
    drop_table :TB_CONTROVERSIA
  end
end
