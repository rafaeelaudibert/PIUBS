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
  belongs_to :controversy, foreign_key: :CO_CONTROVERSIA

  #### DATABASE adaptations ####
  self.primary_key = :CO_SEQ_ID # Setting a different primary_key
  self.table_name = :TB_FEEDBACK # Setting a different table_name

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

  # Configures an alias setter for the CO_CONTROVERSIA database column
  def controversy_id=(value)
    write_attribute(:CO_CONTROVERSIA, value)
  end

  # Configures an alias getter for the CO_CONTROVERSIA database column
  def controversy_id
    read_attribute(:CO_CONTROVERSIA)
  end

  # Configures an alias setter for the DT_CRIADO_EM database column
  def created_at=(value)
    write_attribute(:DT_CRIADO_EM, value)
  end

  # Configures an alias getter for the DT_CRIADO_EM database column
  def created_at
    read_attribute(:DT_CRIADO_EM)
  end
end
