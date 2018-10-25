# frozen_string_literal: true

class AddUuidToAttachments < ActiveRecord::Migration[5.2]
  def change
    remove_column :attachment_links, :attachment_id, :integer
    add_column :attachment_links, :attachment_id, :uuid

    remove_column :attachments, :id, :integer
    add_column :attachments, :id, :uuid, null: false
    execute 'ALTER TABLE attachments ADD PRIMARY KEY (id);'
  end
end
