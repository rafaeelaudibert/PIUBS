class Unity < ApplicationRecord
  belongs_to :city
  has_many :users
  validates :cnes, presence: true, uniqueness: true

  self.primary_key = 'cnes'
end
