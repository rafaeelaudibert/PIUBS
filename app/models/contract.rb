class Contract < ActiveRecord::Base
  belongs_to :city
  belongs_to :company, class_name: 'Company', foreign_key: :sei
end
