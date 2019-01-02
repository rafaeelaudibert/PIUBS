# frozen_string_literal: true

## This class represents a brazilian Unity which must belongs to a City object.
class Unity < ApplicationRecord
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
    write_attribute(:CO_CNES, value)
  end

  # Configures an alias getter for the CO_CNES database column
  def cnes
    read_attribute(:CO_CNES)
  end

  # Configures an alias setter for the NO_NOME database column
  def name=(value)
    write_attribute(:NO_NOME, value)
  end

  # Configures an alias getter for the NO_NOME database column
  def name
    read_attribute(:NO_NOME)
  end

  # Configures an alias setter for the CO_CIDADE database column
  def city_id=(value)
    write_attribute(:CO_CIDADE, value)
  end

  # Configures an alias getter for the CO_CIDADE database column
  def city_id
    read_attribute(:CO_CIDADE)
  end

  # Configures an alias setter for the DS_ENDERECO database column
  def address=(value)
    write_attribute(:DS_ENDERECO, value)
  end

  # Configures an alias getter for the DS_ENDERECO database column
  def address
    read_attribute(:DS_ENDERECO)
  end

  # Configures an alias setter for the DS_BAIRRO database column
  def neighborhood=(value)
    write_attribute(:DS_BAIRRO, value)
  end

  # Configures an alias getter for the DS_BAIRRO database column
  def neighborhood
    read_attribute(:DS_BAIRRO)
  end

  # Configures an alias setter for the DS_TELEFONE database column
  def phone=(value)
    write_attribute(:DS_TELEFONE, value)
  end

  # Configures an alias getter for the DS_TELEFONE database column
  def phone
    read_attribute(:DS_TELEFONE)
  end

  #### FILTERRIFIC queries ####
  filterrific available_filters: %i[search_query]

  scope :search_query, lambda { |query|
    return nil if query.blank?
    return where(CO_CNES: query) if query.class == Integer

    where('"TB_UBS"."NO_NOME" ILIKE :search', search: "%#{query}%")
  }
end
