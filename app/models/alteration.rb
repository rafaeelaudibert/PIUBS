# frozen_string_literal: true

##
# An Alteration is an Event which occurred in a Call or Controversy
# which is not a Reply.
#
# All the possible types for an Alteration,
# are: open_call, close_call, reopen_call, link_call,
# unlink_call, open_controversy, close_controversy, freeze_controversy,
# unfreeze_controversy, to_ministry_controversy, from_ministry_controversy,
# link_support_controversy, unlink_support_controversy, link_city_controversy,
# unlink_city_controversy, link_company_controversy,
# unlink_company_controversy, link_unity_controversy, unlink_unity_controversy,
# link_extra_support_controversy, unlink_extra_support_controversy

class Alteration < ApplicationRecord
  belongs_to :event, foreign_key: :CO_ID

  class CreateError < StandardError
    def initialize(msg = 'Erro na criação da Alteração')
      super
    end
  end

  #### DATABASE adaptations ####
  self.primary_key = :CO_ID # Setting a different primary_key
  self.table_name = :TB_ALTERACAO # Setting a different table_name

  # If update here, update to en.yml
  alias_attribute :type, :CO_TIPO
  enum type: %i[open_call close_call reopen_call
                link_call unlink_call open_controversy
                close_controversy freeze_controversy
                unfreeze_controversy to_ministry_controversy
                from_ministry_controversy link_support_controversy
                unlink_support_controversy link_city_controversy
                unlink_city_controversy link_company_controversy
                unlink_company_controversy link_unity_controversy
                unlink_unity_controversy link_extra_support_controversy
                unlink_extra_support_controversy]

  # Configures an alias setter for the CO_ID database column
  def id=(value)
    write_attribute(:CO_ID, value)
  end

  # Configures an alias getter for the CO_ID database column
  def id
    read_attribute(:CO_ID)
  end

  # Configures an alias setter for the CO_TIPO database column
  def type_id=(value)
    write_attribute(:CO_TIPO, value)
  end

  # Configures an alias getter for the CO_TIPO database column
  def type_id
    read_attribute(:CO_TIPO)
  end
end
