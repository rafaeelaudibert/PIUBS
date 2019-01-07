# frozen_string_literal: true

##
# Principal class in the Apoio as Empresas module.
#
# It is the responsible for managing a problem between a
# Company and a City (and possibly a Unity).
class Call < ApplicationRecord
  before_create :generate_protocol
  after_save :send_mail

  belongs_to :city, foreign_key: :CO_CIDADE
  belongs_to :category, foreign_key: :CO_CATEGORIA
  belongs_to :state, foreign_key: :CO_UF
  belongs_to :company, foreign_key: :CO_SEI
  belongs_to :answer, optional: true, foreign_key: :CO_RESPOSTA
  belongs_to :unity, foreign_key: :CO_CNES
  belongs_to :user, foreign_key: :CO_USUARIO_EMPRESA
  belongs_to :support_user, optional: true, class_name: 'User', foreign_key: :CO_USUARIO_SUPORTE
  has_many :replies, -> { order(CO_SEQ_ID: :DESC) }, as: :repliable, foreign_key: :CO_PROTOCOLO
  has_many :attachment_links, foreign_key: :CO_ATENDIMENTO
  has_many :attachments, through: :attachment_links

  ### Se for adicionado ou alterado algum estado ou severidade,
  ### adicionar tambem na tabela de traducao (config/locales/en.yml)
  alias_attribute :status, :TP_STATUS
  enum status: %i[open closed reopened]

  alias_attribute :severity, :NU_SEVERIDADE
  enum severity: %i[low normal high huge]

  #### DATABASE adaptations ####
  self.primary_key = :CO_PROTOCOLO # Setting a different primary_key
  self.table_name = :TB_ATENDIMENTO # Setting a different table_name

  # Configures an alias setter for the CO_PROTOCOLO database column
  def protocol=(value)
    write_attribute(:CO_PROTOCOLO, value)
  end

  # Configures an alias getter for the CO_PROTOCOLO database column
  def protocol
    read_attribute(:CO_PROTOCOLO)
  end

  # Configures an alias setter for the DS_TITULO database column
  def title=(value)
    write_attribute(:DS_TITULO, value)
  end

  # Configures an alias getter for the DS_TITULO database column
  def title
    read_attribute(:DS_TITULO)
  end

  # Configures an alias setter for the DS_DESCRICAO database column
  def description=(value)
    write_attribute(:DS_DESCRICAO, value)
  end

  # Configures an alias getter for the DS_DESCRICAO database column
  def description
    read_attribute(:DS_DESCRICAO)
  end

  # Configures an alias setter for the DT_FINALIZADO_EM database column
  def finished_at=(value)
    write_attribute(:DT_FINALIZADO_EM, value)
  end

  # Configures an alias getter for the DT_FINALIZADO_EM database column
  def finished_at
    read_attribute(:DT_FINALIZADO_EM)
  end

  # Configures an alias setter for the TP_STATUS database column
  def status=(value)
    write_attribute(:TP_STATUS, value)
  end

  # Configures an alias getter for the TP_STATUS database column
  def status
    read_attribute(:TP_STATUS)
  end

  # Configures an alias setter for the DS_VERSAO_SISTEMA database column
  def version=(value)
    write_attribute(:DS_VERSAO_SISTEMA, value)
  end

  # Configures an alias getter for the DS_VERSAO_SISTEMA database column
  def version
    read_attribute(:DS_VERSAO_SISTEMA)
  end

  # Configures an alias setter for the DS_PERFIL_ACESSO database column
  def access_profile=(value)
    write_attribute(:DS_PERFIL_ACESSO, value)
  end

  # Configures an alias getter for the DS_PERFIL_ACESSO database column
  def access_profile
    read_attribute(:DS_PERFIL_ACESSO)
  end

  # Configures an alias setter for the DS_DETALHE_FUNCIONALIDADE database column
  def feature_detail=(value)
    write_attribute(:DS_DETALHE_FUNCIONALIDADE, value)
  end

  # Configures an alias getter for the DS_DETALHE_FUNCIONALIDADE database column
  def feature_detail
    read_attribute(:DS_DETALHE_FUNCIONALIDADE)
  end

  # Configures an alias setter for the DS_SUMARIO_RESPOSTA database column
  def answer_summary=(value)
    write_attribute(:DS_SUMARIO_RESPOSTA, value)
  end

  # Configures an alias getter for the DS_SUMARIO_RESPOSTA database column
  def answer_summary
    read_attribute(:DS_SUMARIO_RESPOSTA)
  end

  # Configures an alias setter for the CO_CIDADE database column
  def city_id=(value)
    write_attribute(:CO_CIDADE, value)
  end

  # Configures an alias getter for the CO_CIDADE database column
  def city_id
    read_attribute(:CO_CIDADE)
  end

  # Configures an alias setter for the CO_CATEGORIA database column
  def category_id=(value)
    write_attribute(:CO_CATEGORIA, value)
  end

  # Configures an alias getter for the CO_CATEGORIA database column
  def category_id
    read_attribute(:CO_CATEGORIA)
  end

  # Configures an alias setter for the CO_UF database column
  def state_id=(value)
    write_attribute(:CO_UF, value)
  end

  # Configures an alias getter for the CO_UF database column
  def state_id
    read_attribute(:CO_UF)
  end

  # Configures an alias setter for the CO_SEI database column
  def sei=(value)
    write_attribute(:CO_SEI, value)
  end

  # Configures an alias getter for the CO_SEI database column
  def sei
    read_attribute(:CO_SEI)
  end

  # Configures an alias setter for the DT_CRIADO_EM database column
  def created_at=(value)
    write_attribute(:DT_CRIADO_EM, value)
  end

  # Configures an alias getter for the DT_CRIADO_EM database column
  def created_at
    read_attribute(:DT_CRIADO_EM)
  end

  # Configures an alias setter for the CO_USUARIO_EMPRESA database column
  def user_id=(value)
    write_attribute(:CO_USUARIO_EMPRESA, value)
  end

  # Configures an alias getter for the CO_USUARIO_EMPRESA database column
  def user_id
    read_attribute(:CO_USUARIO_EMPRESA)
  end

  # Configures an alias setter for the CO_RESPOSTA database column
  def answer_id=(value)
    write_attribute(:CO_RESPOSTA, value)
  end

  # Configures an alias getter for the CO_RESPOSTA database column
  def answer_id
    read_attribute(:CO_RESPOSTA)
  end

  # Configures an alias setter for the CO_CNES database column
  def cnes=(value)
    write_attribute(:CO_CNES, value)
  end

  # Configures an alias getter for the CO_CNES database column
  def cnes
    read_attribute(:CO_CNES)
  end

  # Configures an alias setter for the CO_USUARIO_SUPORTE database column
  def support_user_id=(value)
    write_attribute(:CO_USUARIO_SUPORTE, value)
  end

  # Configures an alias getter for the CO_USUARIO_SUPORTE database column
  def support_user_id
    read_attribute(:CO_USUARIO_SUPORTE)
  end

  # Configures an alias setter for the NU_SEVERIDADE database column
  def severity=(value)
    write_attribute(:NU_SEVERIDADE, value)
  end

  # Configures an alias getter for the NU_SEVERIDADE database column
  def severity
    read_attribute(:NU_SEVERIDADE)
  end

  # Configures an alias setter for the DT_REABERTO_EM database column
  def reopened_at=(value)
    write_attribute(:DT_REABERTO_EM, value)
  end

  # Configures an alias getter for the DT_REABERTO_EM database column
  def reopened_at
    read_attribute(:DT_REABERTO_EM)
  end

  def self.from_company(sei)
    where(CO_SEI: sei)
  end

  def self.from_company_user(id)
    where(CO_USUARIO_EMPRESA: id)
  end

  def self.from_support_user(id)
    where(CO_USUARIO_SUPORTE: id)
  end

  #### FILTERRIFIC queries ####
  filterrific default_filter_params: { with_status: 'status_any',
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

  scope :search_query, lambda { |query|
    return nil if query.blank?

    where('"DS_TITULO" ILIKE :search OR "DS_DESCRICAO" ILIKE :search', search: "%#{query}%")
  }

  scope :sorted_by_creation, lambda { |sort_key|
    sort = /asc$/.match?(sort_key) ? 'asc' : 'desc'
    case sort_key.to_s
    when /^creation_/
      order(CO_PROTOCOLO: sort)
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
      where(TP_STATUS: @status_i) if @status_i != 4
    else
      raise(ArgumentError, 'Opção de filtro inválida')
    end
  }

  scope :with_ubs, ->(cnes) { cnes == [''] ? nil : where(CO_CNES: cnes) }

  scope :with_company, ->(sei) { sei == [''] ? nil : where(CO_SEI: sei) }

  scope :with_state, ->(state) { state == [''] ? nil : where(CO_UF: state) }

  scope :with_city, ->(city) { city.zero? ? nil : where(CO_CIDADE: city) }

  # Configures the possible filterrific sorting methods
  # to be acessed on CallsController
  def self.options_for_sorted_by_creation
    [
      ['Mais recentes', 'creation_desc'],
      ['Mais antigos', 'creation_asc']
    ]
  end

  # Configures the possible filterrific status options
  # to be acessed on CallsController
  def self.options_for_with_status
    [
      ['Todos Status', 'status_any'],
      %w[Abertos status_open],
      %w[Fechados status_closed],
      %w[Reabertos status_reopened]
    ]
  end

  protected

  # Generate the Call protocol
  def generate_protocol
    self.protocol = 0.seconds.from_now.strftime('%Y%m%d%H%M%S%L').to_i
  end

  # Function responsible for configuring a email to be
  # sent when a new Call is created
  def send_mail
    CallMailer.new_call(self, user).deliver_later
  end
end
