# frozen_string_literal: true

class Call < ApplicationRecord
  before_create :generate_id
  before_create :generate_protocol
  after_save :send_mail

  belongs_to :city, foreign_key: :CO_CIDADE
  belongs_to :category, foreign_key: :CO_CATEGORIA
  belongs_to :state, foreign_key: :CO_UF
  belongs_to :user
  belongs_to :company, foreign_key: :CO_SEI
  belongs_to :answer, optional: true
  belongs_to :unity, foreign_key: :CO_CNES
  has_many :replies, as: :repliable
  has_many :attachment_links
  has_many :attachments, through: :attachment_links

  ### SE ADICIONAR NOVO OU ALTERAR STATUS OU SEVERIDADE, LEMBRAR DE
  ### ADICIONAR TAMBEM NA TRADUCAO (config/locales/en.yml)
  enum status: %i[open closed reopened]
  enum severity: %i[low normal high huge]

  # Configures an alias setter for the CO_SEI database column
  def sei=(value)
    write_attribute(:CO_SEI, value)
  end

  # Configures an alias getter for the CO_SEI database column
  def sei
    read_attribute(:CO_SEI)
  end

  # Configures an alias setter for the CO_UF database column
  def state_id=(value)
    write_attribute(:CO_UF, value)
  end

  # Configures an alias getter for the CO_UF database column
  def state_id
    read_attribute(:CO_UF)
  end

  # Configures an alias setter for the CO_CIDADE database column
  def city_id=(value)
    write_attribute(:CO_CIDADE, value)
  end

  # Configures an alias getter for the CO_CIDADE database column
  def city_id
    read_attribute(:CO_CIDADE)
  end

  # Configures an alias setter for the CO_CNES database column
  def cnes=(value)
    write_attribute(:CO_CNES, value)
  end

  # Configures an alias getter for the CO_CNES database column
  def cnes
    read_attribute(:CO_CNES)
  end

  # Configures an alias setter for the CO_CATEGORIA database column
  def category_id=(value)
    write_attribute(:CO_CATEGORIA, value)
  end

  # Configures an alias getter for the CO_CATEGORIA database column
  def category_id
    read_attribute(:CO_CATEGORIA)
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

    query_search = "%#{query}%"
    where('title ILIKE :search OR description ILIKE :search', search: query_search)
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
      ['Todos Status', 'status_any'],
      %w[Abertos status_open],
      %w[Fechados status_closed],
      %w[Reabertos status_reopened]
    ]
  end

  protected

  def generate_id
    self.id = 0.seconds.from_now.strftime('%Y%m%d%H%M%S%L').to_i
  end

  def generate_protocol
    self.protocol = 0.seconds.from_now.strftime('%Y%m%d%H%M%S%L').to_i
  end

  def send_mail
    CallMailer.new_call(self, user).deliver_later
  end
end
