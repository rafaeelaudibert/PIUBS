class Contract < ActiveRecord::Base
  belongs_to :city
  belongs_to :company, class_name: 'Company', foreign_key: :sei
  validates :contract_number, presence: true, uniqueness: true
  validates :city_id, presence: true
  validates :sei, presence: true
end
