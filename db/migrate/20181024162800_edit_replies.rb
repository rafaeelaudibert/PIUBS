# frozen_string_literal: true

class EditReplies < ActiveRecord::Migration[5.2]
  def change
    remove_column :replies, :protocol, :string

    change_table :replies do |t|
      t.references :repliable, polymorphic: true, index: true
    end
  end
end
