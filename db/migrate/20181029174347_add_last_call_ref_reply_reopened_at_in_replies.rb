class AddLastCallRefReplyReopenedAtInReplies < ActiveRecord::Migration[5.2]
  def change
    add_column :replies, :last_call_ref_reply_reopened_at, :datetime
  end
end
