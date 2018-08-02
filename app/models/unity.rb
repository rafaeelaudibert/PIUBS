class Unity < ApplicationRecord
  belongs_to :city
  self.primary_key = 'cnes'
end
