# frozen_string_literal: true

##
# This class represents a reply from one of the two following models:
# Call or Controversy. Both have the same function, but the CO_CATEGORIA field
# can only contain 'support' or 'company' in the Call model, while can contain the formers
# plus 'city' or 'unity'.
class Reply < ApplicationRecord
  default_scope -> { order(DT_CRIADO_EM: :DESC) }
  belongs_to :event, foreign_key: :CO_ID
  has_one :user, through: :event, foreign_key: :CO_USUARIO
  has_many :attachment_links, foreign_key: :CO_RESPOSTA
  has_many :attachments, through: :attachment_links

  alias_attribute :status, :TP_STATUS
  enum status: %i[open closed reopened]

  ####
  # Error Classes
  ##

  ##
  # Error meant to be reaised when there is an error during
  # the creation of a Reply
  class CreateError < StandardError
    # Reply::CreateError class initialization method
    def initialize(msg = 'Erro na criação da Resposta ')
      super
    end
  end

  #### DATABASE adaptations ####
  self.primary_key = :CO_ID # Setting a different primary_key
  self.table_name = :TB_RESPOSTA # Setting a different table_name

  # Configures an alias setter for the CO_SEQ_ID database column
  def id=(value)
    self[:CO_ID] = value
  end

  # Configures an alias getter for the CO_SEQ_ID database column
  def id
    self[:CO_ID]
  end

  # Configures an alias setter for the DS_DESCRICAO database column
  def description=(value)
    self[:DS_DESCRICAO] = value
  end

  # Configures an alias getter for the DS_DESCRICAO database column
  def description
    self[:DS_DESCRICAO]
  end

  # Configures an alias setter for the ST_FAQ database column,
  # which includes a boolean to string transformation
  def faq=(value)
    self[:ST_FAQ] = if [true, false].include? value
                      value == true ? 'S' : 'N'
                    else
                      value
                    end
  end

  # Configures an alias getter for the ST_FAQ database column
  def faq
    self[:ST_FAQ]
  end

  # Configures an alias getter and setter for the Event DT_CRIADO_EM database column
  delegate :created_at, to: :event

  # Formats created_at attribute
  def formatted_created_at
    created_at.strftime('%d %b %y - %H:%M:%S')
  end

  # Get the agent (Controversy or Call)
  # which created the Event which is parent of this Reply
  def repliable
    event.parent
  end

  #### FILTERRIFIC queries ####
  filterrific available_filters: %i[search_query]

  scope :search_query, lambda { |query|
    return nil if query.blank?
    return where(CO_PROTOCOLO: query) if query.class == Integer

    where('"DS_DESCRICAO" ILIKE :search', search: "%#{query}%")
  }
end
