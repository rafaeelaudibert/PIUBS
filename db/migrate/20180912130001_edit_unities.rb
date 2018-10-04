# frozen_string_literal: true

class EditUnities < ActiveRecord::Migration[5.2]
  def change
    add_column :unities, :address, :string
    add_column :unities, :neighborhood, :string
    add_column :unities, :phone, :string
  end
end
