# frozen_string_literal: true

class Contract < ActiveRecord::Base

  def sei=(value)
    write_attribute(:CO_SEI, value)
  end

  def sei
    read_attribute(:CO_SEI)
  end

  belongs_to :city
  belongs_to :TB_EMPRESA, class_name: 'Company', foreign_key: :CO_SEI
  validates :contract_number, presence: true, uniqueness: true
  validates :city_id, presence: true
  validates :CO_SEI, presence: true

  filterrific(
    default_filter_params: {}, # em breve
    available_filters: %i[search_query]
  )

  scope :search_query, lambda { |query|
    return nil if query.blank?

    where(contract_number: query.to_i)
  }
end
