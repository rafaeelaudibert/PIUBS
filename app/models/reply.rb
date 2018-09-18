class Reply < ApplicationRecord
  belongs_to :user
  belongs_to :call, class_name: 'Call', foreign_key: :protocol
  has_many :attachment_links
  has_many :attachments, through: :attachment_links

  enum status: [:open, :closed, :reopened]
end
