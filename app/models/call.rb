class Call < ApplicationRecord
  belongs_to :city
  belongs_to :category
  belongs_to :state
  belongs_to :user
  belongs_to :company, class_name: 'Company', foreign_key: :sei
  belongs_to :answer, optional: true
  belongs_to :unity, class_name: 'Unity', foreign_key: :cnes
  validates :protocol, presence: true, uniqueness: true
  has_many :replies, class_name: 'Reply', foreign_key: :protocol
  has_many :attachment_links
  has_many :attachments, through: :attachment_links

  enum status: [:open, :closed, :reopened]
  enum severity: [:low, :normal, :high, :huge]
end
