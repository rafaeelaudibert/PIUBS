# frozen_string_literal: true

##
# This class represents a company which have some acess to the PIUBS portal
class Company < ApplicationRecord
  has_many :users, class_name: 'User', foreign_key: :CO_SEI
  has_many :contracts, class_name: 'Contract', foreign_key: :CO_SEI
  has_many :call, class_name: 'Call', foreign_key: :CO_SEI
  has_many :city, -> { order('name ASC') }, through: :contracts
  has_many :state, through: :city
  validates :CO_SEI, presence: true, uniqueness: true

  self.primary_key = :CO_SEI # Setting a different primary_key
  self.table_name = :TB_EMPRESA # Setting a different table_name

  #### DATABASE adaptations ####

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

  # Configures an alias setter for the DT_ATUALIZADO_EM database column
  def updated_at=(value)
    write_attribute(:DT_ATUALIZADO_EM, value)
  end

  # Configures an alias getter for the DT_ATUALIZADO_EM database column
  def updated_at
    read_attribute(:DT_ATUALIZADO_EM)
  end

  #### FILTERRIFIC queries ####
  filterrific(
    default_filter_params: {}, # em breve
    available_filters: %i[search_query]
  )

  scope :search_query, lambda { |query|
    return nil if query.blank? || query.class != Integer

    where(CO_SEI: query.to_i)
  }
end
