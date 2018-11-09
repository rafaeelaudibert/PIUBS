# frozen_string_literal: true

class Reply < ApplicationRecord
  belongs_to :user
  has_many :attachment_links
  has_many :attachments, through: :attachment_links
  belongs_to :repliable, polymorphic: true
  enum status: %i[open closed reopened]

  filterrific(
    default_filter_params: {}, # em breve
    available_filters: %i[search_query]
  )

  scope :search_query, lambda { |query|
    return nil if query.blank?
    return where(repliable_id: query) if query.class == Integer

    where('description ILIKE :search', search: "%#{query}%")
  }
end
