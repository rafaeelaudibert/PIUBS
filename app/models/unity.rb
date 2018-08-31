class Unity < ApplicationRecord
  belongs_to :city
  has_many :users
  has_many :calls
  validates :cnes, presence: true, uniqueness: true

  self.primary_key = 'cnes'
end
