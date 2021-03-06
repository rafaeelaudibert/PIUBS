# frozen_string_literal: true

##
# This represents an Event which can be linked to
# a Reply or an Alteration
class Event < ApplicationRecord
  belongs_to :user, foreign_key: :CO_USUARIO
  belongs_to :system, foreign_key: :CO_SISTEMA_ORIGEM
  belongs_to :type, class_name: 'EventType', foreign_key: :CO_TIPO

  ####
  # Error Classes
  ##

  ##
  # Error meant to be reaised when there is an error during
  # the creation of an Event
  class CreateError < StandardError
    # Event::CreateError class initialization method
    def initialize(msg = 'Erro na criação do Evento ')
      super
    end
  end

  #### DATABASE adaptations ####

  self.primary_key = :CO_SEQ_ID # Setting a different primary_key
  self.table_name = :TB_EVENTO # Setting a different table_name

  # Configures an alias setter for the CO_ID database column
  def id=(value)
    self[:CO_SEQ_ID] = value
  end

  # Configures an alias getter for the CO_ID database column
  def id
    self[:CO_SEQ_ID]
  end

  # Configures an alias setter for the DT_CRIADO_EM database column
  def created_at=(value)
    self[:DT_CRIADO_EM] = value
  end

  # Configures an alias getter for the DT_CRIADO_EM database column
  def created_at
    self[:DT_CRIADO_EM]
  end

  # Configures a getter for a formatted created_at (DT_CRIADO_EM) field
  def formatted_created_at
    created_at.strftime('%d %b %y - %H:%M:%S')
  end

  # Configures an alias setter for the CO_USUARIO database column
  def user_id=(value)
    self[:CO_USUARIO] = value
  end

  # Configures an alias getter for the CO_USUARIO database column
  def user_id
    self[:CO_USUARIO]
  end

  # Configures an alias setter for the CO_PROTOCOLO database column
  def protocol=(value)
    self[:CO_PROTOCOLO] = value
  end

  # Configures an alias getter for the CO_PROTOCOLO database column
  def protocol
    self[:CO_PROTOCOLO]
  end

  # Configures an alias setter for the CO_TIPO database column
  def type_id=(value)
    self[:CO_TIPO] = value
  end

  # Configures an alias getter for the CO_TIPO database column
  def type_id
    self[:CO_TIPO]
  end

  # Configures an alias setter for the CO_SISTEMA_ORIGEM database column
  def system_id=(value)
    self[:CO_SISTEMA_ORIGEM] = value
  end

  # Configures an alias getter for the CO_SISTEMA_ORIGEM database column
  def system_id
    self[:CO_SISTEMA_ORIGEM]
  end

  # Get name of border class to each user role
  def border_class
    user.role.split('_').first.concat('-border')
  end

  ####
  # :section Enum-like methods for EventType
  ##

  # Sets the event to be related with an Alteration
  def alteration!
    self.type = EventType.alteration
    save!
  end

  # Returns true if the event is related to an Alteration
  def alteration?
    type == EventType.alteration
  end

  # Returns the Alteration instance which this Event is related with,
  # if he has a Alteration related to it
  def alteration
    Alteration.find(id) if alteration?
  end

  # Sets the event to be related with a Reply
  def reply!
    self.type = EventType.reply
    save!
  end

  # Returns true if the event is related to a Reply
  def reply?
    type == EventType.reply
  end

  # Returns the Reply instance which this Event is related with,
  # if he has a Reply related to it
  def reply
    Reply.find(id) if reply?
  end

  # Returns the event per-se
  def action
    alteration? ? alteration : reply
  end

  ####
  # :section Enum-like methods for System
  ##

  # Sets the event to be related with a Call
  def from_call!
    self.system = System.call
    save!
  end

  # Returns true if the event is related to a Call
  def from_call?
    system == System.call
  end

  # Returns the Call instance which this Event is related with,
  # if he has a Call related to it
  def call
    Call.find(protocol) if from_call?
  end

  # Sets the event to be related with a Controversy
  def from_controversy!
    self.system = System.controversy
    save!
  end

  # Returns true if the event is related to a Controversy
  def from_controversy?
    system == System.controversy
  end

  # Returns the Controversy instance which this Event is related with,
  # if he has a Controversy related to it
  def controversy
    Controversy.find(protocol) if from_controversy?
  end

  # Returns the event parent per-se
  def parent
    from_call? ? call : controversy
  end
end
