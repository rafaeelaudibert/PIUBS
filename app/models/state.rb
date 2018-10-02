# frozen_string_literal: true

class State < ApplicationRecord
  has_many :cities, -> { order('name ASC') }
  validates :name, presence: true, uniqueness: true
end
