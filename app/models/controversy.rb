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
  has_one :feedback

  enum creator: %i[company unity city support]
  enum category: %i[hardware software]
  enum status: %i[open closed on_hold on_ministry]

  before_create :generate_protocol

  filterrific(
    default_filter_params: {},
    available_filters: %i[search_query]
  )

  scope :search_query, lambda { |query|
    return nil if query.blank?

    query_search = "%#{query}%"
    where('title ILIKE :search OR description ILIKE :search', search: query_search)
  }

  def all_users
    [company_user_id, unity_user_id, city_user_id, support_1_user_id,
     support_2_user_id].reject(&:nil?).map { |user_id| User.find(user_id) }
  end

  def involved_users
    [company_user_id, unity_user_id, city_user_id].reject(&:nil?)
                                                  .map { |user_id| User.find(user_id) }
  end

  protected

  def generate_protocol
    self.protocol = 0.seconds.from_now.strftime('%Y%m%d%H%M%S%L').to_i
  end
end
