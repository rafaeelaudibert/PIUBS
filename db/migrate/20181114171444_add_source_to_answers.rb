class AddSourceToAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :answers, :source, :integer
  end
end
