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

  # Configure an alias to find the 'Apoio a
  # Empresas' system
  def self.call
    find_by(NO_NOME: 'APOIO_A_EMPRESAS')
  end

  # Configure an alias to find the 'Solucao de
  # Controversias' system
  def self.controversy
    find_by(NO_NOME: 'SOLUCAO_DE_CONTROVERSIAS')
  end
end
