# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    private

    def timestamp_attributes_for_create
      super << 'DT_CRIADO_EM'
    end

    def timestamp_attributes_for_update
      super << 'DT_ATUALIZADO_EM'
    end
  end
end
