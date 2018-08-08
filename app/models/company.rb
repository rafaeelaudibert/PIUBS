class Company < ApplicationRecord
  has_many :user, class_name: "User", foreign_key: :sei
  has_many :contract
  self.primary_key = 'sei' # Setting a different primary_key
end
