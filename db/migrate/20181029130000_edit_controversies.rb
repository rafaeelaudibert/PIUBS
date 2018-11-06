# frozen_string_literal: true

class EditControversies < ActiveRecord::Migration[5.2]
  def change
    remove_column :controversies, :support_1_id, :integer
    remove_column :controversies, :support_2_id, :integer

    change_table :controversies do |t|
      t.integer :support_1_user_id
      t.integer :support_2_user_id
    end

    add_foreign_key :controversies, :users, column: :support_1_user_id
    add_foreign_key :controversies, :users, column: :support_2_user_id
  end
end
