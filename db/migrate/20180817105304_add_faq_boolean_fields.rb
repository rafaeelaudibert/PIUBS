# frozen_string_literal: true

class AddFaqBooleanFields < ActiveRecord::Migration[5.2]
  def change
    add_column :answers, :faq, :boolean, default: false
    add_column :replies, :faq, :boolean, default: false
  end
end
