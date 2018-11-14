# frozen_string_literal: true

class Company < ApplicationRecord
  has_many :user, class_name: 'User', foreign_key: :sei
  has_many :contracts, class_name: 'Contract', foreign_key: :sei
  has_many :call, class_name: 'Call', foreign_key: :sei
  has_many :city, -> { order('name ASC') }, through: :contracts
  has_many :state, through: :city
  validates :sei, presence: true, uniqueness: true

  self.primary_key = 'sei' # Setting a different primary_key

  filterrific(
    default_filter_params: {}, # em breve
    available_filters: %i[search_query]
  )

  scope :search_query, lambda { |query|
    return nil if query.blank? || query.class != Integer

    query_search_i = query.to_i
    where('sei = ?', query_search_i)
  }
end
