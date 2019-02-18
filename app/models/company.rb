# frozen_string_literal: true

##
# This class represents a company which have acess to the PIUBS portal
#
# A Company can make part of a Contract settled with a City. This
# Contract makes so that the Company need to give support to all the Unity instances
# which are from the city.
#
# A Company can have more than one Contract.
class Company < ApplicationRecord
  has_many :users, foreign_key: :CO_SEI
  has_many :contracts, foreign_key: :CO_SEI
  has_many :call, foreign_key: :CO_SEI
  has_many :cities, -> { order('name ASC') }, through: :contracts
  validates :CO_SEI, presence: true, uniqueness: true
  validates :NU_CNPJ, presence: true, uniqueness: true
  validates_cnpj_format_of :NU_CNPJ, options: { allow_blank: true, allow_nil: true }

  #### DATABASE adaptations ####
  self.primary_key = :CO_SEI # Setting a different primary_key
  self.table_name = :TB_EMPRESA # Setting a different table_name

  # Configures an alias setter for the CO_SEI database column
  def sei=(value)
    self[:CO_SEI] = value
  end

  # Configures an alias getter for the CO_SEI database column
  def sei
    self[:CO_SEI]
  end

  # Configures an alias setter for the NO_NOME database column
  def name=(value)
    self[:NO_NOME] = value
  end

  # Configures an alias getter for the NO_NOME database column
  def name
    self[:NO_NOME]
  end

  # Configures an alias setter for the NU_CNPJ database column
  def cnpj=(value)
    self[:NU_CNPJ] = value
  end

  # Configures an alias getter for the NU_CNPJ database column
  def cnpj
    self[:NU_CNPJ]
  end

  # Configures an alias setter for the DT_CRIADO_EM database column
  def created_at=(value)
    self[:DT_CRIADO_EM] = value
  end

  # Configures an alias getter for the DT_CRIADO_EM database column
  def created_at
    self[:DT_CRIADO_EM]
  end

  # Return all the State instances which are related to a City
  # which has a relation with this Company through a Contract
  def states
    State.where(CO_CODIGO: contracts.map { |c| c.city.state_id }.sort.uniq!).order(:NO_NOME)
  end

  # Return all the City instances from a State (which is retrieved
  # based in the <tt>id</tt> parameter) which are related to this
  # Company through a Contract
  def cities_from_state(id)
    State.find(id).cities.where(CO_CODIGO: contracts.map(&:city_id)).order('"NO_NOME"')
  end

  #### FILTERRIFIC queries ####
  filterrific available_filters: %i[search_query]

  scope :search_query, lambda { |query|
    return nil if query.blank? || query.class != Integer

    where(CO_SEI: query.to_i)
  }
end
