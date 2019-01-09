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

  def states
    State.where(CO_CODIGO: contracts.map { |c| c.city.state_id }.sort.uniq!).order(:NO_NOME)
  end

  #### DATABASE adaptations ####
  self.primary_key = :CO_SEI # Setting a different primary_key
  self.table_name = :TB_EMPRESA # Setting a different table_name

  # Configures an alias setter for the CO_SEI database column
  def sei=(value)
    write_attribute(:CO_SEI, value)
  end

  # Configures an alias getter for the CO_SEI database column
  def sei
    read_attribute(:CO_SEI)
  end

  # Configures an alias setter for the DT_CRIADO_EM database column
  def created_at=(value)
    write_attribute(:DT_CRIADO_EM, value)
  end

  # Configures an alias getter for the DT_CRIADO_EM database column
  def created_at
    read_attribute(:DT_CRIADO_EM)
  end

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
