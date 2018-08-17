class AddAnswerToCalls < ActiveRecord::Migration[5.2]
  def change
    add_reference :calls, :answer, foreign_key: true
  end
end
