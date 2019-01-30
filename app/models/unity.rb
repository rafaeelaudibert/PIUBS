# frozen_string_literal: true

## This class represents a brazilian Unity which must belongs to a City object.
class Unity < ApplicationRecord
  default_scope -> { joins(:city).order(Arel.sql('"TB_CIDADE"."NO_NOME"'), Arel.sql('"TB_UBS"."NO_NOME"')) }
  belongs_to :city, foreign_key: :CO_CIDADE
  has_many :users, foreign_key: :CO_CNES
  has_many :calls, foreign_key: :CO_CNES
  validates :CO_CNES, presence: true, uniqueness: true
  validates :NO_NOME, presence: true
  validates :CO_CIDADE, presence: true

  #### DATABASE adaptations ####

  self.primary_key = :CO_CNES
  self.table_name = :TB_UBS

  # Configures an alias setter for the CO_CNES database column
  def cnes=(value)
    self[:CO_CNES] = value
  end

  # Configures an alias getter for the CO_CNES database column
  def cnes
    self[:CO_CNES]
  end

  # Configures an alias setter for the NO_NOME database column
  def name=(value)
    self[:NO_NOME] = value
  end

  # Configures an alias getter for the NO_NOME database column
  def name
    self[:NO_NOME]
  end

  # Configures an alias setter for the CO_CIDADE database column
  def city_id=(value)
    self[:CO_CIDADE] = value
  end

  # Configures an alias getter for the CO_CIDADE database column
  def city_id
    self[:CO_CIDADE]
  end

  # Configures an alias setter for the DS_ENDERECO database column
  def address=(value)
    self[:DS_ENDERECO] = value
  end

  # Configures an alias getter for the DS_ENDERECO database column
  def address
    self[:DS_ENDERECO]
  end

  # Configures an alias setter for the DS_BAIRRO database column
  def neighborhood=(value)
    self[:DS_BAIRRO] = value
  end

  # Configures an alias getter for the DS_BAIRRO database column
  def neighborhood
    self[:DS_BAIRRO]
  end

  # Configures an alias setter for the DS_TELEFONE database column
  def phone=(value)
    self[:DS_TELEFONE] = value
  end

  # Configures an alias getter for the DS_TELEFONE database column
  def phone
    self[:DS_TELEFONE]
  end

  #### FILTERRIFIC queries ####
  filterrific available_filters: %i[search_query with_state with_city]

  scope :search_query, lambda { |query|
    return nil if query.blank?
    return where(CO_CNES: query) if query.class == Integer

    where('"TB_UBS"."NO_NOME" ILIKE :search', search: "%#{query}%")
  }

  scope :with_state, ->(state) { state == [''] ? nil : where(city: State.find(state).cities) }

  scope :with_city, ->(city) { city.zero? ? nil : where(city: city) }
end
