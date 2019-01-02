# frozen_string_literal: true

class CreateCalls < ActiveRecord::Migration[5.2]
  def change
    create_table :calls do |t|
      t.string :title
      t.text :description
      t.datetime :finished_at
      t.integer :status
      t.string :version
      t.string :access_profile
      t.string :feature_detail
      t.string :answer_summary
      t.string :severity
      t.string :protocol
      t.references :category, foreign_key: true
      t.integer :CO_SEI
      t.integer :CO_UF
      t.integer :CO_CIDADE

      t.timestamps
    end
    add_foreign_key :calls, :TB_EMPRESA, column: :CO_SEI, primary_key: :CO_SEI
    add_foreign_key :calls, :TB_UF, column: :CO_UF, primary_key: :CO_CODIGO
    add_foreign_key :calls, :TB_CIDADE, column: :CO_CIDADE, primary_key: :CO_CODIGO
  end
end
