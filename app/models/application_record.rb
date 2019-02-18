# frozen_string_literal: true

##
# This class represents the default model, which all
# the others will inherit from
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    private

    # Add the custom 'DT_CRIADO_EM' as a column the application should
    # monitor as a column to be updated when we create a new entry in the DB
    def timestamp_attributes_for_create
      super << 'DT_CRIADO_EM'
    end

    # Add the custom 'DT_ATUALIZADO_EM' as a column the application should
    # monitor as a column to be updated when we update a entry in the DB
    def timestamp_attributes_for_update
      super << 'DT_ATUALIZADO_EM'
    end
  end
end
