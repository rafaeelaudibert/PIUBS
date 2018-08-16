class Call < ApplicationRecord
  belongs_to :city
  belongs_to :category
  belongs_to :state
  belongs_to :company, class_name: 'Company', foreign_key: :sei
  has_many :replies, class_name: 'Reply', foreign_key: :protocol
end
