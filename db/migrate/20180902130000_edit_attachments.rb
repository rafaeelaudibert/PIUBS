class EditAttachments < ActiveRecord::Migration[5.2]
  def change
    remove_column :attachments, :answer_id, :references

    create_table :attachment_links do |t|
      t.references :answer
      t.references :reply
      t.references :call
      t.integer :source

      t.timestamps
    end
  end
end
