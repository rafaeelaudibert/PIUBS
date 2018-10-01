# frozen_string_literal: true

class State < ApplicationRecord
  has_many :cities, -> { order('name DESC')}
  validates :name, presence: true, uniqueness: true
end
