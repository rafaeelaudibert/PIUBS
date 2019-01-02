# frozen_string_literal: true

class City < ApplicationRecord
  belongs_to :state, class_name: 'State', foreign_key: :CO_UF
  has_many :unities, -> { order('name ASC') }
  has_many :users
  has_one :contract
  validates :name, presence: true

  # Configures an alias setter for the CO_UF database column
  def state_id=(value)
    write_attribute(:CO_UF, value)
  end

  # Configures an alias getter for the CO_UF database column
  def state_id
    read_attribute(:CO_UF)
  end

  filterrific(
    default_filter_params: { sorted_by_name: 'name_asc' },
    available_filters: %i[search_query with_state sorted_by_name]
  )

  scope :sorted_by_name, lambda { |sort_key|
    sort = sort_key.match?(/asc$/) ? 'asc' : 'desc'

    case sort_key.to_s
    when /^name_/
      order(name: sort)
    else
      raise(ArgumentError, 'Invalid filter option')
    end
  }

  def self.options_for_sorted_by_name
    [
      ['Cidade [A-Z]', 'name_asc'],
      ['Cidade [Z-A]', 'name_desc']
    ]
  end

  scope :with_state, lambda { |state|
    return [] if state == ['']

    where(state_id: state) if state != ['']
  }

  scope :search_query, lambda { |query|
    return nil if query.blank?

    query_search = "%#{query}%"
    where('cities.name ILIKE :search', search: query_search)
  }
end
