# frozen_string_literal: true

class EditAttachmentLinksWithControversies < ActiveRecord::Migration[5.2]
  def change
    add_column :attachment_links, :controversy_id, :string
    add_foreign_key :attachment_links, :controversies, primary_key: :protocol
  end
end
