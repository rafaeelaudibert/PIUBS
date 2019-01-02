# frozen_string_literal: true

##
# This class represents a brazilian state which must have a name and an abbreviation of 2 letters.
#
# Each state can have multiple City child instances.
class State < ApplicationRecord
  default_scope { order(:NO_NOME) }
  has_many :cities, -> { order(NO_NOME: :ASC) }
  has_many :unities, through: :cities
  has_many :users, through: :cities
  validates :NO_NOME, presence: true, uniqueness: true
  validates :SG_SIGLA, presence: true, uniqueness: true, length: { is: 2 }

  #### DATABASE adaptations ####

  self.primary_key = :CO_CODIGO # Setting a different primary_key
  self.table_name = :TB_UF # Setting a different table_name

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

  # Configures an alias setter for the SG_SIGLA database column
  def abbr=(value)
    write_attribute(:SG_SIGLA, value)
  end

  # Configures an alias getter for the SG_SIGLA database column
  def abbr
    read_attribute(:SG_SIGLA)
  end

  #### FILTERRIFIC queries ####
  filterrific available_filters: %i[search_query]

  scope :search_query, lambda { |query|
    return nil if query.blank?

    query_search = "%#{query}%"
    where('"NO_NOME" ILIKE :search', search: query_search)
  }
end
