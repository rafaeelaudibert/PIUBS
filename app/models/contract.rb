# frozen_string_literal: true

##
# This class represents a Contract between a City and a Company
#
# It must contain an attachment in the application/pdf MIME format.
# This attachment is stored as a BLOB in the database
#--
# FIXME: Use NFS to store the contracts instead of a BLOB field
# FIXME: DT_CRIADO_EM is not being saved (why though?)
#++
class Contract < ApplicationRecord
  default_scope -> { order(Arel.sql('"CO_CODIGO"')) }
  belongs_to :city, foreign_key: :CO_CIDADE
  belongs_to :company, foreign_key: :CO_SEI
  validates :CO_CODIGO, presence: true, uniqueness: true
  validates :CO_CIDADE, presence: true
  validates :CO_SEI, presence: true
  validates :NO_NOME_ARQUIVO, presence: true
  validate :pdf?

  # Validation method responsible for verifying in the backend if the sent file is a pdf
  def pdf?
    errors.add(:DS_TIPO_ARQUIVO, 'is not a PDF file') unless content_type == 'application/pdf'
  end

  #### DATABASE adaptations ####

  self.primary_key = :CO_CODIGO # Setting a different primary_key
  self.table_name = :TB_CONTRATO # Setting a different table_name

  # Configures an alias setter for the CO_CONTRATO database column
  def contract_number=(value)
    self[:CO_CODIGO] = value
  end

  # Configures an alias getter for the CO_CONTRATO database column
  def contract_number
    self[:CO_CODIGO]
  end

  # Configures an alias setter for the CO_CIDADE database column
  def city_id=(value)
    self[:CO_CIDADE] = value
  end

  # Configures an alias getter for the CO_CIDADE database column
  def city_id
    self[:CO_CIDADE]
  end

  # Configures an alias setter for the CO_SEI database column
  def sei=(value)
    self[:CO_SEI] = value
  end

  # Configures an alias getter for the CO_SEI database column
  def sei
    self[:CO_SEI]
  end

  # Configures an alias setter for the NO_NOME_ARQUIVO database column
  def filename=(value)
    self[:NO_NOME_ARQUIVO] = value
  end

  # Configures an alias getter for the NO_NOME_ARQUIVO database column
  def filename
    self[:NO_NOME_ARQUIVO]
  end

  # Configures an alias setter for the DS_TIPO_ARQUIVO database column
  def content_type=(value)
    self[:DS_TIPO_ARQUIVO] = value
  end

  # Configures an alias getter for the DS_TIPO_ARQUIVO database column
  def content_type
    self[:DS_TIPO_ARQUIVO]
  end

  # Configures an alias setter for the BL_CONTEUDO database column
  def file_contents=(value)
    self[:BL_CONTEUDO] = value
  end

  # Configures an alias getter for the BL_CONTEUDO database column
  def file_contents
    self[:BL_CONTEUDO]
  end

  # Configures an alias setter for the DT_CRIADO_EM database column
  def created_at=(value)
    self[:DT_CRIADO_EM] = value
  end

  # Configures an alias getter for the DT_CRIADO_EM database column
  def created_at
    self[:DT_CRIADO_EM]
  end

  # Returns the relative address of the link where you
  # can download the Contract
  def download_link
    "/contract/#{id}/download"
  end

  # Return all the contracts which belongs to a Company instance
  def from_company(sei)
    where(CO_SEI: sei)
  end

  # Return the state of the City instance related with this Contract
  delegate :state, to: :city

  #### FILTERRIFIC queries ####
  filterrific available_filters: %i[search_query]

  scope :search_query, lambda { |query|
    return nil if query.blank?

    where(contract_number: query.to_i)
  }
end
