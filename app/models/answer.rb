class Answer < ApplicationRecord
  belongs_to :category
  belongs_to :user
  has_many :attachment
end
