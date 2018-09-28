# frozen_string_literal: true

class CreateReplies < ActiveRecord::Migration[5.2]
  def change
    create_table :replies do |t|
      t.string :protocol
      t.text :description
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
