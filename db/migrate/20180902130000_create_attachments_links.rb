# frozen_string_literal: true

class CreateAttachmentsLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :attachment_links do |t|
      t.references :answer
      t.references :reply
      t.references :call
      t.integer :source
      t.uuid :CO_ANEXO, null: false

      t.timestamps
    end

    add_foreign_key :attachment_links, :TB_ANEXO, column: :CO_ANEXO, primary_key: :CO_ID
  end
end
