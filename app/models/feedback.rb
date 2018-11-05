class Feedback < ApplicationRecord
  has_many :attachment_links
  has_many :attachments, through: :attachment_links
  belongs_to :controversy
end
