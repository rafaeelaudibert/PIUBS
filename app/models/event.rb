# frozen_string_literal: true

##
# This represents an Event which can be linked to
# a Reply or an Alteration
class Event < ApplicationRecord
  belongs_to :user, foreign_key: :CO_USUARIO
  belongs_to :system, foreign_key: :CO_SISTEMA_ORIGEM
  belongs_to :event_type, foreign_key: :CO_TIPO

  #### DATABASE adaptations ####

  self.primary_key = :CO_SEQ_ID # Setting a different primary_key
  self.table_name = :TB_EVENTO # Setting a different table_name

  # Configures an alias setter for the CO_ID database column
  def id=(value)
    write_attribute(:CO_SEQ_ID, value)
  end

  # Configures an alias getter for the CO_ID database column
  def id
    read_attribute(:CO_SEQ_ID)
  end

  # Configures an alias setter for the DT_DATA database column
  def date=(value)
    write_attribute(:DT_DATA, value)
  end

  # Configures an alias getter for the DT_DATA database column
  def date
    read_attribute(:DT_DATA)
  end

  # Configures an alias setter for the CO_USUARIO database column
  def user_id=(value)
    write_attribute(:CO_USUARIO, value)
  end

  # Configures an alias getter for the CO_USUARIO database column
  def user_id
    read_attribute(:CO_USUARIO)
  end

  # Configures an alias setter for the CO_PROTOCOLO database column
  def protocol=(value)
    write_attribute(:CO_PROTOCOLO, value)
  end

  # Configures an alias getter for the CO_PROTOCOLO database column
  def protocol
    read_attribute(:CO_PROTOCOLO)
  end

  # Configures an alias setter for the CO_TIPO database column
  def type_id=(value)
    write_attribute(:CO_TIPO, value)
  end

  # Configures an alias getter for the CO_TIPO database column
  def type_id
    read_attribute(:CO_TIPO)
  end

  # Configures an alias setter for the CO_SISTEMA_ORIGEM database column
  def system_id=(value)
    write_attribute(:CO_SISTEMA_ORIGEM, value)
  end

  # Configures an alias getter for the CO_SISTEMA_ORIGEM database column
  def system_id
    read_attribute(:CO_SISTEMA_ORIGEM)
  end

  ####
  # :section Enum-like methods for EventType
  ##

  # Returns the event per-se
  def action
    alteration? ? Alteration.find(id) : Reply.find(id)
  end

  # Sets the event to be related with an Alteration
  def alteration!
    self.event_type = 1
    save!
  end

  # Returns true if the event is related to an Alteration
  def alteration?
    event_type == 1
  end

  # Sets the event to be related with a Reply
  def reply!
    self.event_type = 2
    save!
  end

  # Returns true if the event is related to a Reply
  def reply?
    event_type == 2
  end

  ####
  # :section Enum-like methods for System
  ##

  # Sets the event to be related with a Call
  def from_call!
    self.system_id = 1
    save!
  end

  # Returns true if the event is related to a Call
  def from_call?
    system_id == 1
  end

  # Sets the event to be related with a Controversy
  def from_controversy!
    self.system_id = 2
    save!
  end

  # Returns true if the event is related to a Controversy
  def from_controversy?
    system_id == 2
  end
end
