# frozen_string_literal: true

class EditAttachmentLinksWithControversies < ActiveRecord::Migration[5.2]
  def change
    add_column :RT_LINK_ANEXO, :CO_CONTROVERSIA, :bigint
    add_foreign_key :RT_LINK_ANEXO, :TB_CONTROVERSIA, column: :CO_CONTROVERSIA, primary_key: :CO_PROTOCOLO
  end
end
