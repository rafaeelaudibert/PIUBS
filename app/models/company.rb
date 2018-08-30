class Company < ApplicationRecord
  has_many :user, class_name: 'User', foreign_key: :sei
  has_many :contracts, class_name: 'Contract', foreign_key: :sei
  has_many :call, class_name: 'Call', foreign_key: :sei
  validates :sei, presence: true, uniqueness: true

  self.primary_key = 'sei' # Setting a different primary_key
end
