# frozen_string_literal: true

class AddCategoryToReply < ActiveRecord::Migration[5.2]
  def change
    add_column :replies, :category, :string
  end
end
