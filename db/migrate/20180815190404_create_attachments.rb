class CreateAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :attachments do |t|
      t.string :filename
      t.string :content_type
      t.binary :file_contents
      t.references :answer, foreign_key: true

      t.timestamps
    end
  end
end
