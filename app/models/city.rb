# frozen_string_literal: true

class City < ApplicationRecord
  belongs_to :state
  has_many :unities, -> { order('name ASC') }
  has_many :users
  has_one :contract
  validates :name, presence: true

  filterrific(
    default_filter_params: {}, # em breve
    available_filters: %i[search_query]
  )

  scope :search_query, lambda { |query|
    return nil if query.blank?

    query_search = "%#{query}%"
    where('cities.name ILIKE :search', search: query_search)
  }
end
