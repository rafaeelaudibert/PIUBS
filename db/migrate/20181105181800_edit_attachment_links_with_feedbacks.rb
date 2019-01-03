# frozen_string_literal: true

class EditAttachmentLinksWithFeedbacks < ActiveRecord::Migration[5.2]
  def change
    add_column :RT_LINK_ANEXO, :CO_FEEDBACK, :integer
    add_foreign_key :RT_LINK_ANEXO, :TB_FEEDBACK, column: :CO_FEEDBACK, primary_key: :CO_SEQ_ID
  end
end
