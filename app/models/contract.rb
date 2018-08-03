class Contract < ApplicationRecord
  belongs_to :city
  has_one :company

  mount_uploader :files, ContractUploader
end
