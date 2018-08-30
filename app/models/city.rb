class City < ApplicationRecord
  belongs_to :state
  has_many :unity
  has_many :users
  has_one :contract
  validates :name, presence: true, uniqueness: true
end
