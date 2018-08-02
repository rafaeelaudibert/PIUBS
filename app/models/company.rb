class Company < ApplicationRecord
  has_many :user
  self.primary_key = 'sei'
end
