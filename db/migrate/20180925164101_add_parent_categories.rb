# frozen_string_literal: true

class AddParentCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :parent_id, :integer
    add_column :categories, :parent_depth, :integer, default: 0
    add_column :categories, :severity, :integer
  end
end
