class AddSourceToAnswersAndCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :source, :integer
    add_column :answers, :source, :integer
  end
end
