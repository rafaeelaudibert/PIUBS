# frozen_string_literal: true

class AddSupportUserToCalls < ActiveRecord::Migration[5.2]
  def change
    add_column :calls, :support_user, :integer
    add_foreign_key :calls, :users, column: :support_user, primary_key: :id
  end
end
