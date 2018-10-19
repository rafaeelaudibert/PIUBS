# frozen_string_literal: true

class State < ApplicationRecord
  has_many :cities, -> { order('name ASC') }
  validates :name, presence: true, uniqueness: true

  filterrific(
    default_filter_params: {}, # em breve
    available_filters: %i[search_query]
  )

  scope :search_query, lambda { |query|
    return nil if query.blank?

    query_search = "%#{query}%"
    where('name ILIKE :search', search: query_search)
  }
end
