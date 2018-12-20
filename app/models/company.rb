# frozen_string_literal: true

class Company < ApplicationRecord

  self.table_name = :TB_EMPRESA

  def sei=(value)
    write_attribute(:CO_SEI, value)
  end

  def sei
    read_attribute(:CO_SEI)
  end

  def created_at=(value)
    write_attribute(:DT_CRIADO_EM, value)
  end

  def created_at
    read_attribute(:DT_CRIADO_EM)
  end

  def updated_at=(value)
    write_attribute(:DT_ATUALIZADO_EM, value)
  end

  def updated_at
    read_attribute(:DT_ATUALIZADO_EM)
  end


  has_many :users, class_name: 'User', foreign_key: :CO_SEI
  has_many :contracts, class_name: 'Contract', foreign_key: :CO_SEI
  has_many :call, class_name: 'Call', foreign_key: :CO_SEI
  has_many :city, -> { order('name ASC') }, through: :contracts
  has_many :state, through: :city
  validates :CO_SEI, presence: true, uniqueness: true

  self.primary_key = :CO_SEI # Setting a different primary_key

  filterrific(
    default_filter_params: {}, # em breve
    available_filters: %i[search_query]
  )

  scope :search_query, lambda { |query|
    return nil if query.blank? || query.class != Integer

    query_search_i = query.to_i
    where('CO_SEI = ?', query_search_i)
  }
end
