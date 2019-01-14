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

  # Returns all Controversies instances which are related to
  # the User instance with <tt>id</tt> equal as
  # the one passed as a paremter, through the
  # <tt>support_user</tt> relation
  def self.from_support_user(id)
    where('"CO_SUPORTE" = :id OR "CO_SUPORTE_ADICIONAL" = :id', id: "%#{id}%")
  end

  def self.from_company(sei)
    where(sei: sei)
  end

  def self.from_company_user(id)
    where(company_user_id: id)
  end

  def self.from_ubs_admin(cnes)
    where(cnes: cnes)
  end

  def self.from_ubs_user(id)
    where(unity_user_id: id)
  end

  def self.from_city_user(id)
    where(city_user_id: id)
  end

  filterrific(
    default_filter_params: { with_status: 'status_any',
                             sorted_by_creation: 'creation_desc' },
    available_filters: %i[
      sorted_by_creation
      with_status
      with_ubs
      with_company
      with_state
      with_city
      search_query
    ]
  )

  scope :search_query, lambda { |query|
    return nil if query.blank?
    return where(protocol: query) if query.class == Integer

    where('"title" ILIKE :search OR "description" ILIKE :search', search: "%#{query}%")
  }

  scope :sorted_by_creation, lambda { |sort_key|
    sort = /asc$/.match?(sort_key) ? 'asc' : 'desc'
    case sort_key.to_s
    when /^creation_/
      order(protocol: sort)
    else
      raise(ArgumentError, 'Invalid filter option')
    end
  }

  scope :with_status, lambda { |filter_key|
    @status_i = if /open$/.match?(filter_key)
                  0
                elsif /closed$/.match?(filter_key)
                  1
                elsif /on_hold$/.match?(filter_key)
                  2
                elsif /on_ministry$/.match?(filter_key)
                  3
                else
                  4
                end

    case filter_key.to_s
    when /^status_/
      where(status: @status_i) if @status_i != 4
    else
      raise(ArgumentError, 'Opção de filtro inválida')
    end
  }

  scope :with_ubs, ->(cnes) { cnes == [''] ? nil : where(cnes: cnes) }

  scope :with_company, ->(sei) { sei == [''] ? nil : where(sei: sei) }

  scope :with_state, ->(state) { state == [''] ? nil : where(city: State.find(state).cities) }

  scope :with_city, ->(city) { city.zero? ? nil : where(city: city) }

  # Configures the possible filterrific sorting methods
  # to be acessed on ControversiesController
  def self.options_for_sorted_by_creation
    [
      ['Mais recentes', 'creation_desc'],
      ['Mais antigos', 'creation_asc']
    ]
  end

  # Configures the possible filterrific status options
  # to be acessed on ControversiesController
  def self.options_for_with_status
    [
      ['Todos Status', 'status_any'],
      %w[Abertos status_open],
      %w[Fechados status_closed],
      ['No aguardo', 'status_on_hold'],
      ['Com Ministério', 'status_on_ministry']
    ]
  end

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
