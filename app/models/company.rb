class Company < ApplicationRecord
  has_many :user
  has_many :contract

  self.primary_key = 'sei' # Setting a different primary_key
end
