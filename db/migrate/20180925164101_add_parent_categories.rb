class AddParentCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :parent_id, :integer
    add_column :categories, :severity, :integer
  end
end
