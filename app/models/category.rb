# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :answer
  validates :name, presence: true, uniqueness: true
  validates :parent, presence: false, uniquenes: false

  belongs_to :parent, class_name: :Category,
                      foreign_key: :parent_id, optional: true
  has_many :children, ->(category) { where(parent_id: category.id) },
           class_name: :Category

  enum severity: %i[low medium high]
  enum source: %i[from_call from_controversy]

  filterrific(
    default_filter_params: {}, # em breve
    available_filters: %i[search_query]
  )

  scope :search_query, lambda { |query|
    return nil if query.blank?

    query_search = "%#{query}%"
    where('name ILIKE :search', search: query_search)
  }
end
