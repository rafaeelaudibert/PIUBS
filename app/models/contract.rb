# frozen_string_literal: true

class Contract < ActiveRecord::Base
  belongs_to :city
  belongs_to :company, class_name: 'Company', foreign_key: :sei
  validates :contract_number, presence: true, uniqueness: true
  validates :city_id, presence: true
  validates :sei, presence: true

  filterrific(
    default_filter_params: { # em breve
     },
    available_filters: %i[
      search_query
    ]
  )

  scope :search_query, lambda { |query|
    return nil  if query.blank?
    query_search_i = query.to_i
    where("contract_number = ?", query_search_i)
  }
end
