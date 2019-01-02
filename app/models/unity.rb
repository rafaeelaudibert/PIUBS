# frozen_string_literal: true

class Unity < ApplicationRecord
  belongs_to :city, foreign_key: :CO_CIDADE
  has_many :users
  has_many :calls
  validates :cnes, presence: true, uniqueness: true

  self.primary_key = 'cnes'

  # Configures an alias setter for the CO_CIDADE database column
  def city_id=(value)
    write_attribute(:CO_CIDADE, value)
  end

  # Configures an alias getter for the CO_CIDADE database column
  def city_id
    read_attribute(:CO_CIDADE)
  end

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
