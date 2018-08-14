class AddUserToCalls < ActiveRecord::Migration[5.2]
  def change
    add_reference :calls, :user, foreign_key: true
  end
end
