# frozen_string_literal: true

##
# This class is the responsible to link an Attachment with
# any attachable model, which are: Call, Reply, Answer,
# Controversy or Feedback
#
# We shall have a relation table because the same attachment,
# can have relations with tons of differents other entities.
class AttachmentLink < ApplicationRecord
  belongs_to :attachment, foreign_key: :CO_ANEXO
  belongs_to :answer, optional: true, foreign_key: :CO_QUESTAO
  belongs_to :call, optional: true, foreign_key: :CO_ATENDIMENTO, primary_key: :CO_PROTOCOLO
  belongs_to :reply, optional: true, foreign_key: :CO_RESPOSTA
  belongs_to :controversy, optional: true, foreign_key: :CO_CONTROVERSIA
  belongs_to :feedback, optional: true, foreign_key: :CO_FEEDBACK, primary_key: :CO_PROTOCOLO
  validates :TP_ENTIDADE_ORIGEM, presence: true

  alias_attribute :source, :TP_ENTIDADE_ORIGEM
  enum source: %i[answer call reply controversy feedback]

  ####
  # Error Classes
  ##

  ##
  # Error meant to be reaised when there is an error during
  # the creation of an AttachmentLink
  #
  # It also handles the deletion of links created previously,
  # which refer to the same Attachment
  class CreateError < StandardError
    # AttachmentLink::CreateError class initialization method
    def initialize(msg = 'Erro ao tentar associas os anexos ', links: [])
      links.each(&:delete)
      super(msg)
    end
  end

  #### DATABASE adaptations ####
  self.primary_key = :CO_ID # Setting a different primary_key
  self.table_name = :RT_LINK_ANEXO # Setting a different table_name

  # Configures an alias setter for the CO_ID database column
  def id=(value)
    self[:CO_ID] = value
  end

  # Configures an alias getter for the CO_ID database column
  def id
    self[:CO_ID]
  end

  # Configures an alias setter for the CO_ANEXO database column
  def attachment_id=(value)
    self[:CO_ANEXO] = value
  end

  # Configures an alias getter for the CO_ANEXO database column
  def attachment_id
    self[:CO_ANEXO]
  end

  # Configures an alias setter for the CO_RESPOSTA database column
  def reply_id=(value)
    self[:CO_RESPOSTA] = value
  end

  # Configures an alias getter for the CO_RESPOSTA database column
  def reply_id
    self[:CO_RESPOSTA]
  end

  # Configures an alias setter for the CO_ATENDIMENTO database column
  def call_id=(value)
    self[:CO_ATENDIMENTO] = value
  end

  # Configures an alias getter for the CO_ATENDIMENTO database column
  def call_id
    self[:CO_ATENDIMENTO]
  end

  # Configures an alias setter for the CO_QUESTAO database column
  def answer_id=(value)
    self[:CO_QUESTAO] = value
  end

  # Configures an alias getter for the CO_QUESTAO database column
  def answer_id
    self[:CO_QUESTAO]
  end

  # Configures an alias setter for the CO_CONTROVERSIA database column
  def controversy_id=(value)
    self[:CO_CONTROVERSIA] = value
  end

  # Configures an alias getter for the CO_CONTROVERSIA database column
  def controversy_id
    self[:CO_CONTROVERSIA]
  end

  # Configures an alias setter for the CO_FEEDBACK database column
  def feedback_id=(value)
    self[:CO_FEEDBACK] = value
  end

  # Configures an alias getter for the CO_FEEDBACK database column
  def feedback_id
    self[:CO_FEEDBACK]
  end

  # Configures an alias setter for the TP_ENTIDADE_ORIGEM database column
  def source=(value)
    self[:TP_ENTIDADE_ORIGEM] = value
  end

  # Configures an alias getter for the TP_ENTIDADE_ORIGEM database column
  def source
    self[:TP_ENTIDADE_ORIGEM]
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
