# frozen_string_literal: true

class Controversy < ApplicationRecord
  belongs_to :company, foreign_key: :sei
  belongs_to :contract
  belongs_to :city
  belongs_to :unity, foreign_key: :cnes
  belongs_to :company_user, class_name: 'User', optional: true
  belongs_to :unity_user, class_name: 'User', optional: true
  belongs_to :support_1, class_name: 'User', optional: true
  belongs_to :support_2, class_name: 'User', optional: true
  has_many :attachment_links
  has_many :attachments, through: :attachment_links

  enum creator: %i[company unity]
  enum category: %i[hardware software]
  enum status: %i[open closed]
end
