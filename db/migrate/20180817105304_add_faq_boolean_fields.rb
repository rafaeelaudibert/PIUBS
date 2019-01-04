# frozen_string_literal: true

class AddFaqBooleanFields < ActiveRecord::Migration[5.2]
  def change
    add_column :replies, :faq, :boolean, default: false
  end
end
