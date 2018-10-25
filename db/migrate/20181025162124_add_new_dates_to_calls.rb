class AddNewDatesToCalls < ActiveRecord::Migration[5.2]
  def change
    add_column :calls, :reopened_at, :datetime
  end
end
