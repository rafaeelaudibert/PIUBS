# frozen_string_literal: true

class Unity < ApplicationRecord
  belongs_to :city
  has_many :users
  has_many :calls
  validates :cnes, presence: true, uniqueness: true

  self.primary_key = 'cnes'

  filterrific(
    default_filter_params: {}, # em breve
    available_filters: %i[search_query]
  )

  scope :search_query, lambda { |query|
    return nil if query.blank?
    return where(cnes: query) if query.class == Integer

    where('unities.name ILIKE :search', search: "%#{query}%")
  }
end
