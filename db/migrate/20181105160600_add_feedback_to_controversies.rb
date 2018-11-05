class AddFeedbackToControversies < ActiveRecord::Migration[5.2]
  def change
    add_column :controversies, :feedback, :string
  end
end
