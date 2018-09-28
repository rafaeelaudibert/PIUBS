# frozen_string_literal: true

class State < ApplicationRecord
  has_many :city
  validates :name, presence: true, uniqueness: true
end
