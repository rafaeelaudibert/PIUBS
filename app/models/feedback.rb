# frozen_string_literal: true

##
# A instance of this class is created when a Controversy
# is closed.
#
# Every Controversy must have a final report which are stored
# for a future brazilian government auditory
class Feedback < ApplicationRecord
  has_many :attachment_links, foreign_key: :CO_FEEDBACK
  has_many :attachments, through: :attachment_links
  belongs_to :controversy, foreign_key: :CO_PROTOCOLO

  ####
  # Error Classes
  ##

  ##
  # Error meant to be reaised when there is an error during
  # the creation of a Feedback
  class CreateError < StandardError
    # Feedback::CreateError class initialization method
    def initialize(msg = 'Erro na criação da Resposta Final ')
      super
    end
  end

  #### DATABASE adaptations ####
  self.primary_key = :CO_PROTOCOLO # Setting a different primary_key
  self.table_name = :TB_FEEDBACK # Setting a different table_name

  # Configures an alias setter for the CO_PROTOCOLO database column
  def id=(value)
    self[:CO_PROTOCOLO] = value
  end

  # Configures an alias getter for the CO_PROTOCOLO database column
  def id
    self[:CO_PROTOCOLO]
  end

  # Configures another alias setter for the CO_PROTOCOLO database column
  def controversy_id=(value)
    self[:CO_PROTOCOLO] = value
  end

  # Configures another alias getter for the CO_PROTOCOLO database column
  def controversy_id
    self[:CO_PROTOCOLO]
  end

  # Configures an alias setter for the DS_DESCRICAO database column
  def description=(value)
    self[:DS_DESCRICAO] = value
  end

  # Configures an alias getter for the DS_DESCRICAO database column
  def description
    self[:DS_DESCRICAO]
  end

  # Configures an alias setter for the DT_CRIADO_EM database column
  def created_at=(value)
    self[:DT_CRIADO_EM] = value
  end

  # Configures an alias getter for the DT_CRIADO_EM database column
  def created_at
    self[:DT_CRIADO_EM]
  end
end
