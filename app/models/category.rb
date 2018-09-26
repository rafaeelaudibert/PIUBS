class Category < ApplicationRecord
  has_many :answer
  validates :name, presence: true, uniqueness: true
  validates :parent, presence: false, uniquenes: false

  belongs_to :parent, class_name: :Category, foreign_key: :parent_id, optional: true
  enum severity: %i[low medium high]
end
