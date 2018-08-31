class Category < ApplicationRecord
  has_many :answer
  validates :name, presence: true, uniqueness: true
end
