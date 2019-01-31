# frozen_string_literal: true

class CreateCompanies < ActiveRecord::Migration[5.2]
  def self.up
    create_table :TB_EMPRESA, id: false do |t|
      t.bigint :CO_SEI, null: false
      t.string :NO_NOME, null: false
      t.string :NU_CNPJ, null: false, limit: 18
      t.datetime :DT_CRIADO_EM
    end

    execute 'ALTER TABLE "TB_EMPRESA" ADD CONSTRAINT "PK_TB_EMPRESA" PRIMARY KEY ("CO_SEI");'
  end

  def self.down
    drop_table :TB_EMPRESA
  end
end
