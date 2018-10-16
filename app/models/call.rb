# frozen_string_literal: true

class Call < ApplicationRecord
  belongs_to :city
  belongs_to :category
  belongs_to :state
  belongs_to :user
  belongs_to :company, class_name: 'Company', foreign_key: :sei
  belongs_to :answer, optional: true
  belongs_to :unity, class_name: 'Unity', foreign_key: :cnes
  validates :protocol, presence: true, uniqueness: true
  has_many :replies, class_name: 'Reply', foreign_key: :protocol
  has_many :attachment_links
  has_many :attachments, through: :attachment_links

  ### SE ADICIONAR NOVO OU ALTERAR STATUS OU SEVERIDADE, LEMBRAR DE
  ### ADICIONAR TAMBEM NA TRADUCAO (config/locales/en.yml)
  enum status: %i[open closed reopened]
  enum severity: %i[low normal high huge]

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
    return nil  if query.blank?
    query_search = "%#{query}%"
    where("title ILIKE :search OR description ILIKE :search", search: query_search)
  }

  scope :sorted_by_creation, lambda { |sort_key|
    sort = /asc$/.match?(sort_key) ? 'asc' : 'desc'
    case sort_key.to_s
    when /^creation_/
      order(id: sort)
    else
      raise(ArgumentError, 'Invalid filter option')
    end
  }

  scope :with_status, lambda { |filter_key|
    @status_i = if /open$/.match?(filter_key)
                  0
                elsif /closed$/.match?(filter_key)
                  1
                elsif /reopened$/.match?(filter_key)
                  2
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

  scope :with_ubs, lambda { |cnes|
    return nil if cnes == ['']

    where(cnes: cnes) if cnes != ['']
  }

  scope :with_company, lambda { |sei|
    return nil if sei == ['']

    where(sei: sei) if sei != ['']
  }

  scope :with_state, lambda { |state|
    return [] if state == ['']

    where(state_id: state) if state != ['']
  }

  scope :with_city, lambda { |city|
    where(city_id: city) unless city.zero?
  }

  def self.options_for_sorted_by_creation
    [
      ['Mais recentes', 'creation_desc'],
      ['Mais antigos', 'creation_asc']
    ]
  end

  def self.options_for_with_status
    [
      %w[Status status_any],
      %w[Abertos status_open],
      %w[Fechados status_closed],
      %w[Reabertos status_reopened]
    ]
  end

  def self.options_for_with_city
    [
      ['Cidade', 0]
    ]
  end
end
