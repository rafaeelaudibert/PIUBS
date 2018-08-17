class AddStatusToReply < ActiveRecord::Migration[5.2]
  def change
    add_column :replies, :status, :integer
  end
end
