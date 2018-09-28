# frozen_string_literal: true

class Company < ApplicationRecord
  has_many :user, class_name: 'User', foreign_key: :sei
  has_many :contracts, class_name: 'Contract', foreign_key: :sei
  has_many :call, class_name: 'Call', foreign_key: :sei
  has_many :city, through: :contracts
  has_many :state, through: :city
  validates :sei, presence: true, uniqueness: true

  self.primary_key = 'sei' # Setting a different primary_key
end
