# frozen_string_literal: true

##
# This class hold all the possible types for an Event,
# which are instances of: Alteration or Reply

class EventType < ApplicationRecord
  #### DATABASE adaptations ####

  self.primary_key = :CO_SEQ_ID # Setting a different primary_key
  self.table_name = :TB_TIPO_EVENTO # Setting a different table_name

  # Configures an alias setter for the CO_ID database column
  def id=(value)
    self[:CO_SEQ_ID] = value
  end

  # Configures an alias getter for the CO_ID database column
  def id
    self[:CO_SEQ_ID]
  end

  # Configures an alias setter for the NO_NOME database column
  def name=(value)
    self[:NO_NOME] = value
  end

  # Configures an alias getter for the NO_NOME database column
  def name
    self[:NO_NOME]
  end

  ####
  # Configures a enum-like for the instances on this table, which can
  # only be Alteration or Reply
  ##

  # Returns the EventType instance which represents an Alteration
  def self.alteration
    find_by(NO_NOME: 'ALTERATION')
  end

  # Returns the EventType instance which represents a Reply
  def self.reply
    find_by(NO_NOME: 'REPLY')
  end
end
