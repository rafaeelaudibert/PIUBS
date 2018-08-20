class Contract < ActiveRecord::Base
  belongs_to :city
  has_one :company, class_name: "Company", foreign_key: :sei
end
