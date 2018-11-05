# frozen_string_literal: true

class EditAttachmentLinksWithFeedbacks < ActiveRecord::Migration[5.2]
  def change
    add_column :attachment_links, :feedback_id, :integer
    add_foreign_key :attachment_links, :feedbacks
  end
end
