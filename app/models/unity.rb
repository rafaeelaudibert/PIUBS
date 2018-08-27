class Unity < ApplicationRecord
  belongs_to :city
  has_many :users
  self.primary_key = 'cnes'
end
