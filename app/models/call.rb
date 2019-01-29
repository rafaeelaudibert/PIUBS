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
  belongs_to :company, foreign_key: :CO_SEI
  belongs_to :answer, optional: true, foreign_key: :CO_RESPOSTA
  belongs_to :unity, foreign_key: :CO_CNES
  belongs_to :user, foreign_key: :CO_USUARIO_EMPRESA
  belongs_to :support_user, optional: true, class_name: 'User', foreign_key: :CO_USUARIO_SUPORTE
  has_many :events, -> { order(CO_SEQ_ID: :DESC) }, foreign_key: :CO_PROTOCOLO
  has_many :attachment_links, foreign_key: :CO_ATENDIMENTO
  has_many :attachments, through: :attachment_links

  ####
  # Error Classes
  ##

  ##
  # Error meant to be reaised when there is an error during
  # the creation of a Call
  class CreateError < StandardError
    # Call::CreateError class initialization method
    def initialize(msg = 'Erro na criação do Atendimento ')
      super
    end
  end

  ##
  # Error meant to be reaised when there is an error during
  # the update of a Call
  class UpdateError < StandardError
    # Call::UpdateError class initialization method
    def initialize(msg = 'Ocorreu um erro ao tentar atualizar o Atendimento ')
      super
    end
  end

  ##
  # Error meant to be reaised when there is an error during
  # the alteration of the <tt>support_user</tt> field, if a
  # User instance which is not referenced in the former field,
  # tries to make that column <tt>nil</tt>
  class OwnerError < StandardError
    # Call::OwnerError class initialization method
    def initialize(msg = 'Você não é o usuário responsável por esse Atendimento')
      super
    end
  end

  ##
  # Error meant to be reaised when there is an error during
  # the alteration of the <tt>support_user</tt> field, trying to
  # reference a User instance, when there is already a User
  # referenced.
  class AlreadyTakenError < StandardError
    # Call::AlreadyTakenError class initialization method
    def initialize(msg = 'Esse Atendimento já pertence a outro usuário do suporte')
      super
    end
  end

  # If some status or severity is changed or added
  # update the translation table as well (config/locales/en.yml)
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

  # Configures a getter for a formatted created_at (DT_CRIADO_EM) field
  def formatted_created_at
    created_at.strftime('%d %b %y - %H:%M:%S')
  end

  # Configures an alias setter for the DT_REABERTO_EM database column
  def reopened_at=(value)
    write_attribute(:DT_REABERTO_EM, value)
  end

  # Configures an alias getter for the DT_REABERTO_EM database column
  def reopened_at
    read_attribute(:DT_REABERTO_EM)
  end

  # Configures a getter for a formatted created_at (DT_REABERTO_EM) field
  def formatted_reopened_at
    reopened_at.strftime('%d %b %y - %H:%M:%S')
  end

  # Configures an alias setter for the DT_FINALIZADO_EM database column
  def finished_at=(value)
    write_attribute(:DT_FINALIZADO_EM, value)
  end

  # Configures an alias getter for the DT_FINALIZADO_EM database column
  def finished_at
    read_attribute(:DT_FINALIZADO_EM)
  end

  # Configures a getter for a formatted finished_at (DT_FINALIZADO_EM) field
  def formatted_finished_at
    finished_at.strftime('%d %b %y - %H:%M:%S')
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

  # Configures an alias to get the State instance which is related to this Call
  # through the City
  def state
    city.state
  end

  # Closes a call configuring it closed_at column
  def close!
    update(TP_STATUS: 'closed', DT_FINALIZADO_EM: 0.seconds.from_now)
  end

  # Returns all Call instances which are related to
  # the Company instance with <tt>sei</tt> equal as
  # the one passed as a paremter
  def self.from_company(sei)
    where(CO_SEI: sei)
  end

  # Returns all Call instances which are related to
  # the User instance with <tt>id</tt> equal as
  # the one passed as a paremter, through the
  # <tt>company_user</tt> relation
  def self.from_company_user(id)
    where(CO_USUARIO_EMPRESA: id)
  end

  # Returns all Call instances which are related to
  # the User instance with <tt>id</tt> equal as
  # the one passed as a paremter, through the
  # <tt>support_user</tt> relation
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

  scope :with_state, ->(state) { state == [''] ? nil : city.where(CO_UF: state) }

  scope :with_city, ->(city) { city.zero? ? nil : where(CO_CIDADE: city) }

  # Filterrific method
  #
  # Configures the possible filterrific sorting methods
  # to be acessed on CallsController
  def self.options_for_sorted_by_creation
    [
      ['Mais recentes', 'creation_desc'],
      ['Mais antigos', 'creation_asc']
    ]
  end

  # Filterrifict method
  #
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
