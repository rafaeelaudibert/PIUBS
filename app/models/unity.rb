# frozen_string_literal: true

class Unity < ApplicationRecord
  belongs_to :city
  has_many :users
  has_many :calls
  validates :cnes, presence: true, uniqueness: true

  self.primary_key = 'cnes'

  filterrific(
    default_filter_params: {}, # em breve
    available_filters: %i[
      search_query
      with_state
      with_city
    ]
  )

  scope :search_query, lambda { |query|
    return nil if query.blank?
    return where(cnes: query) if query.class == Integer

    where('unities.name ILIKE :search', search: "%#{query}%")
  }

  scope :with_state, ->(state) { state == [''] ? nil : where(city: State.find(state).cities) }

  scope :with_city, ->(city) { city.zero? ? nil : where(city: city) }

end
