class Company < ApplicationRecord
  has_many :user, class_name: "User", foreign_key: :sei
  has_many :contract, class_name: "Contract", foreign_key: :sei
  has_many :call, class_name: "Call", foreign_key: :sei
  self.primary_key = 'sei' # Setting a different primary_key
end
