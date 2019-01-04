# frozen_string_literal: true

##
# This class represents a reply from one of the two following models:
# Call or Controversy. Both have the same function, but the CO_CATEGORIA field
# can only contain 'support' or 'company' in the Call model, while can contain the formers
# plus 'city' or 'unity'.
class Reply < ApplicationRecord
  belongs_to :user, foreign_key: :CO_USUARIO
  has_many :attachment_links, foreign_key: :CO_RESPOSTA
  has_many :attachments, through: :attachment_links
  belongs_to :repliable, polymorphic: true,
                         foreign_key: :CO_PROTOCOLO

  alias_attribute :status, :TP_STATUS
  enum status: %i[open closed reopened]

  #### DATABASE adaptations ####
  self.primary_key = :CO_SEQ_ID # Setting a different primary_key
  self.table_name = :TB_RESPOSTA # Setting a different table_name

  # Configures an alias setter for the CO_SEQ_ID database column
  def id=(value)
    write_attribute(:CO_SEQ_ID, value)
  end

  # Configures an alias getter for the CO_SEQ_ID database column
  def id
    read_attribute(:CO_SEQ_ID)
  end

  # Configures an alias setter for the DS_DESCRICAO database column
  def description=(value)
    write_attribute(:DS_DESCRICAO, value)
  end

  # Configures an alias getter for the DS_DESCRICAO database column
  def description
    read_attribute(:DS_DESCRICAO)
  end

  # Configures an alias setter for the CO_CATEGORIA database column
  def category=(value)
    write_attribute(:CO_CATEGORIA, value)
  end

  # Configures an alias getter for the CO_CATEGORIA database column
  def category
    read_attribute(:CO_CATEGORIA)
  end

  # Configures an alias setter for the ST_FAQ database column,
  # which includes a boolean to string transformation
  def faq=(value)
    if [true, false].include? value
      write_attribute(:ST_FAQ, value == true ? 'S' : 'N')
    else
      write_attribute(:ST_FAQ, value)
    end
  end

  # Configures an alias getter for the ST_FAQ database column
  def faq
    read_attribute(:ST_FAQ)
  end

  # Configures an alias setter for the CO_PROTOCOLO database column
  def repliable_id=(value)
    write_attribute(:CO_PROTOCOLO, value)
  end

  # Configures an alias getter for the CO_PROTOCOLO database column
  def repliable_id
    read_attribute(:CO_PROTOCOLO)
  end

  # Configures an alias setter for the CO_USUARIO database column
  def user_id=(value)
    write_attribute(:CO_USUARIO, value)
  end

  # Configures an alias getter for the CO_USUARIO database column
  def user_id
    read_attribute(:CO_USUARIO)
  end

  # Configures an alias setter for the TP_STATUS database column
  def status=(value)
    write_attribute(:TP_STATUS, value)
  end

  # Configures an alias getter for the TP_STATUS database column
  def status
    read_attribute(:TP_STATUS)
  end

  # Configures an alias setter for the TP_STATUS database column
  def created_at=(value)
    write_attribute(:TP_STATUS, value)
  end

  # Configures an alias getter for the TP_STATUS database column
  def created_at
    read_attribute(:TP_STATUS)
  end

  # Configures an alias setter for the DT_REF_ATENDIMENTO_FECHADO database column
  def last_call_ref_reply_closed_at=(value)
    write_attribute(:DT_REF_ATENDIMENTO_FECHADO, value)
  end

  # Configures an alias getter for the DT_REF_ATENDIMENTO_FECHADO database column
  def last_call_ref_reply_closed_at
    read_attribute(:DT_REF_ATENDIMENTO_FECHADO)
  end

  # Configures an alias setter for the DT_REF_ATENDIMENTO_REABERTO database column
  def last_call_ref_reply_reopened_at=(value)
    write_attribute(:DT_REF_ATENDIMENTO_REABERTO, value)
  end

  # Configures an alias getter for the DT_REF_ATENDIMENTO_REABERTO database column
  def last_call_ref_reply_reopened_at
    read_attribute(:DT_REF_ATENDIMENTO_REABERTO)
  end

  #### FILTERRIFIC queries ####
  filterrific available_filters: %i[search_query]

  scope :search_query, lambda { |query|
    return nil if query.blank?
    return where(CO_PROTOCOLO: query) if query.class == Integer

    where('"DS_DESCRICAO" ILIKE :search', search: "%#{query}%")
  }
end
