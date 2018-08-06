class City < ApplicationRecord
  belongs_to :state
  has_many :unity
  has_one :contract
end
