class EditAttachmentsLinks < ActiveRecord::Migration[5.2]
  def change
    add_column :attachment_links, :attachment_id, :integer, limit: 8
    add_foreign_key :attachment_links, :attachments
  end
end
