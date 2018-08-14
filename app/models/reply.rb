class Reply < ApplicationRecord
  belongs_to :user
  belongs_to :call, class_name: "Call", foreign_key: :protocol
end
