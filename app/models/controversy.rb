# frozen_string_literal: true

class Controversy < ApplicationRecord
  belongs_to :company, foreign_key: :sei
  belongs_to :contract, optional: true
  belongs_to :city
  belongs_to :unity, foreign_key: :cnes, optional: true
  belongs_to :company_user, class_name: 'User', optional: true
  belongs_to :unity_user, class_name: 'User', optional: true
  belongs_to :city_user, class_name: 'User', optional: true
  belongs_to :support_1, foreign_key: :support_1_user_id, class_name: 'User', optional: true
  belongs_to :support_2, foreign_key: :support_2_user_id, class_name: 'User', optional: true
  has_many :attachment_links
  has_many :attachments, through: :attachment_links
  has_many :replies, as: :repliable

  enum creator: %i[company unity city support]
  enum category: %i[hardware software]
  enum status: %i[open closed]

  before_create :generate_protocol

  protected

  def generate_protocol
    self.protocol = Time.now.strftime('%Y%m%d%H%M%S%L').to_i
  end
end
