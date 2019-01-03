# frozen_string_literal: true

##
# This class represents a brazilian City which must belongs to an State object.
#
# Each City can have multiple Unity child instances.
#
# Each City can also have a Contract which will link it together with a Company, which
# is the responsible for administrating its Unity instances.
class City < ApplicationRecord
  belongs_to :state, foreign_key: :CO_UF
  has_many :unities, -> { order(NO_NOME: :ASC) }, foreign_key: :CO_CIDADE
  has_many :users, -> { order(id: :ASC) }, foreign_key: :CO_CIDADE
  has_one :contract, foreign_key: :CO_CIDADE
  validates :NO_NOME, presence: true
  validates :CO_UF, presence: true

  #### DATABASE adaptations ####

  self.primary_key = :CO_CODIGO # Setting a different primary_key
  self.table_name = :TB_CIDADE # Setting a different table_name

  # Configures an alias setter for the CO_CODIGO database column
  def id=(value)
    write_attribute(:CO_CODIGO, value)
  end

  # Configures an alias getter for the CO_CODIGO database column
  def id
    read_attribute(:CO_CODIGO)
  end

  # Configures an alias setter for the NO_NOME database column
  def name=(value)
    write_attribute(:NO_NOME, value)
  end

  # Configures an alias getter for the NO_NOME database column
  def name
    read_attribute(:NO_NOME)
  end

  # Configures an alias setter for the CO_UF database column
  def state_id=(value)
    write_attribute(:CO_UF, value)
  end

  # Configures an alias getter for the CO_UF database column
  def state_id
    read_attribute(:CO_UF)
  end

  #### FILTERRIFIC queries ####
  filterrific default_filter_params: { sorted_by_name: 'name_asc' },
              available_filters: %i[search_query with_state sorted_by_name]

  # Configures the possible filterrific sorting methods to be acessed on CitiesController
  def self.options_for_sorted_by_name
    [
      ['Cidade [A-Z]', 'name_asc'],
      ['Cidade [Z-A]', 'name_desc']
    ]
  end

  scope :sorted_by_name, lambda { |sort_key|
    sort = sort_key.match?(/asc$/) ? 'asc' : 'desc'

    case sort_key.to_s
    when /^name_/
      order(NO_NOME: sort)
    else
      raise(ArgumentError, 'Invalid filter option')
    end
  }

  scope :with_state, lambda { |state_id|
    return [] if state_id == ['']

    where(CO_UF: state_id)
  }

  scope :search_query, lambda { |query|
    return nil if query.blank?

    query_search = "%#{query}%"
    where('cities.name ILIKE :search', search: query_search)
  }
end
