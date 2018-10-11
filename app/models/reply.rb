# frozen_string_literal: true

class Reply < ApplicationRecord
  belongs_to :user
  belongs_to :call, class_name: 'Call', foreign_key: :protocol
  has_many :attachment_links
  has_many :attachments, through: :attachment_links

  enum status: %i[open closed reopened]

  filterrific(
    default_filter_params: { # em breve
     },
    available_filters: %i[
      search_query
    ]
  )

  scope :search_query, lambda { |query|
    return nil  if query.blank?
    query_search = "%#{query}%"
    where("protocol ILIKE :search OR description ILIKE :search", search: query_search)
  }
end
