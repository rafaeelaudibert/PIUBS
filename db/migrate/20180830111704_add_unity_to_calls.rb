# frozen_string_literal: true

class AddUnityToCalls < ActiveRecord::Migration[5.2]
  def change
    add_column :calls, :CO_CNES, :integer
    add_foreign_key :calls, :TB_UBS, column: :CO_CNES, primary_key: :CO_CNES
  end
end
