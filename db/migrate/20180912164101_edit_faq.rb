# frozen_string_literal: true

class EditFaq < ActiveRecord::Migration[5.2]
  def change
    add_column :answers, :keywords, :string
  end
end
