class Contract < ActiveRecord::Base
  belongs_to :city
  has_one :company
end
