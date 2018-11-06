class CreateFeedbacks < ActiveRecord::Migration[5.2]
  def change
    create_table :feedbacks do |t|
      t.string :description
      t.references :controversy

      t.timestamps
    end
  end
end
