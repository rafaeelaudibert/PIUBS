# frozen_string_literal: true

class CreateAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :answers do |t|
      t.text :question
      t.text :answer
      t.references :user, foreign_key: true
      t.integer :CO_CATEGORIA

      t.timestamps
    end

    add_foreign_key :answers, :TB_CATEGORIA, column: :CO_CATEGORIA, primary_key: :CO_SEQ_ID
  end
end
