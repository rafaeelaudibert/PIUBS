class Attachment < ApplicationRecord
  has_many :attachment_links
  has_many :calls, through: :attachment_links
  has_many :replies, through: :attachment_links
  has_many :answers, through: :attachment_links
end
