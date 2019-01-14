# frozen_string_literal: true

##
# This class hold all the possible types for an Alteration,
# which are: open_call, close_call, reopen_call, link_call,
# unlink_call, open_controversy, close_controversy, freeze_controversy,
# unfreeze_controversy, to_ministry_controversy, from_ministry_controversy,
# link_support_controversy, unlink_support_controversy, link_city_controversy,
# unlink_city_controversy, link_company_controversy, unlink_company_controversy,
# link_unity_controversy, unlink_unity_controversy, link_extra_support_controversy,
# unlink_extra_support_controversy

class AlterationType < ApplicationRecord
  #### DATABASE adaptations ####

  self.primary_key = :CO_SEQ_ID # Setting a different primary_key
  self.table_name = :TB_TIPO_ALTERACAO # Setting a different table_name

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
