# frozen_string_literal: true

##
# This class represents a System which represent the possible
# system contained in this project.
#
# Today, this systems are Solucao de Controversias e Apoio a Empresas

class System < ApplicationRecord
  #### DATABASE adaptations ####

  self.primary_key = :CO_SEQ_ID # Setting a different primary_key
  self.table_name = :TB_SISTEMA # Setting a different table_name

  # Configures an alias setter for the CO_ID database column
  def id=(value)
    write_attribute(:CO_SEQ_ID, value)
  end

  # Configures an alias getter for the CO_ID database column
  def id
    read_attribute(:CO_SEQ_ID)
  end

  # Configures an alias setter for the NO_NOME database column
  def name=(value)
    write_attribute(:NO_NOME, value)
  end

  # Configures an alias getter for the NO_NOME database column
  def name
    read_attribute(:NO_NOME)
  end
end
