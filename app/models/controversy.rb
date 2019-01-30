# frozen_string_literal: true

##
# Principal class in the Solucao de Controversias module.
#
# It is the responsible for managing a problem between a
# Company and a City (and possibly a Unity).
#
# When a Controversy is closed, a Feedback will be generated,
# containing relevant informations about the former.

class Controversy < ApplicationRecord
  before_create :generate_protocol

  belongs_to :company, foreign_key: :CO_SEI
  belongs_to :category, foreign_key: :CO_CATEGORIA
  belongs_to :city, foreign_key: :CO_CIDADE
  belongs_to :unity, foreign_key: :CO_CNES, optional: true
  belongs_to :creator, class_name: 'User', optional: true, foreign_key: :CO_CRIADO_POR
  belongs_to :company_user, class_name: 'User', optional: true, foreign_key: :CO_USUARIO_EMPRESA
  belongs_to :unity_user, class_name: 'User', optional: true, foreign_key: :CO_USUARIO_UNIDADE
  belongs_to :city_user, class_name: 'User', optional: true, foreign_key: :CO_USUARIO_CIDADE
  belongs_to :support_1, foreign_key: :CO_SUPORTE, class_name: 'User', optional: true
  belongs_to :support_2, foreign_key: :CO_SUPORTE_ADICIONAL, class_name: 'User', optional: true
  has_many :attachment_links, foreign_key: :CO_CONTROVERSIA
  has_many :attachments, through: :attachment_links
  has_many :events, -> { order(CO_SEQ_ID: :DESC) }, foreign_key: :CO_PROTOCOLO
  has_one :feedback, foreign_key: :CO_PROTOCOLO

  alias_attribute :status, :TP_STATUS
  enum status: %i[open closed on_hold on_ministry]

  #### DATABASE adaptations ####
  self.primary_key = :CO_PROTOCOLO # Setting a different primary_key
  self.table_name = :TB_CONTROVERSIA # Setting a different table_name

  ####
  # Error Classes
  ##

  ##
  # Error meant to be reaised when there is an error during
  # the creation of a Controversy
  class CreateError < StandardError
    # Controversy::CreateError class initialization method
    def initialize(msg = 'Erro na criação da Controvérsia ')
      super
    end
  end

  ##
  # Error meant to be reaised when there is an error during
  # the update of a Controversy
  class UpdateError < StandardError
    # Controversy::UpdateError class initialization method
    def initialize(msg = 'Erro ao tentar atualizar a Controvérsia ')
      super
    end
  end

  ##
  # Error meant to be reaised when there is an error during
  # the update of a User instance related to a Controversy
  class UserUpdateError < StandardError
    # Controversy::UserUpdateError class initialization method
    def initialize(msg = 'Erro ao tentar atualizar o usuário relacionado à Controvérsia ')
      super
    end
  end

  ##
  # Error meant to be reaised when there is an error during
  # the alteration of the <tt>support_1</tt> field, trying to
  # reference a User instance, when there is already a User
  # referenced.
  class AlreadyTakenError < StandardError
    # Controversy::AlreadyTakenError class initialization method
    def initialize(msg = 'Você não pode pegar uma controvérsia de outro usuário do suporte')
      super
    end
  end

  ##
  # Error meant to be reaised when there is an error during
  # the alteration of the <tt>support_1</tt> field, if a
  # User instance which is not referenced in the former field,
  # tries to make that column <tt>nil</tt>
  class OwnerError < StandardError
    # Controversy::OwnerError class initialization method
    def initialize(msg = 'Essa controvérsia pertence a outro usuário do suporte ')
      super
    end
  end

  # Configures an alias setter for the CO_PROTOCOLO database column
  def protocol=(value)
    self[:CO_PROTOCOLO] = value
  end

  # Configures an alias getter for the CO_PROTOCOLO database column
  def protocol
    self[:CO_PROTOCOLO]
  end

  # Configures an alias setter for the DS_TITULO database column
  def title=(value)
    self[:DS_TITULO] = value
  end

  # Configures an alias getter for the DS_TITULO database column
  def title
    self[:DS_TITULO]
  end

  # Configures an alias setter for the DS_DESCRICAO database column
  def description=(value)
    self[:DS_DESCRICAO] = value
  end

  # Configures an alias getter for the DS_DESCRICAO database column
  def description
    self[:DS_DESCRICAO]
  end

  # Configures an alias setter for the DT_FINALIZADO_EM database column
  def closed_at=(value)
    self[:DT_FINALIZADO_EM] = value
  end

  # Configures an alias getter for the DT_FINALIZADO_EM database column
  def closed_at
    self[:DT_FINALIZADO_EM]
  end

  # Configures an alias setter for the TP_STATUS database column
  def status=(value)
    self[:TP_STATUS] = value
  end

  # Configures an alias getter for the TP_STATUS database column
  def status
    self[:TP_STATUS]
  end

  # Configures an alias setter for the CO_SEI database column
  def sei=(value)
    self[:CO_SEI] = value
  end

  # Configures an alias getter for the CO_SEI database column
  def sei
    self[:CO_SEI]
  end

  # Configures an alias setter for the CO_CIDADE database column
  def city_id=(value)
    self[:CO_CIDADE] = value
  end

  # Configures an alias getter for the CO_CIDADE database column
  def city_id
    self[:CO_CIDADE]
  end

  # Configures an alias setter for the CO_CNES database column
  def cnes=(value)
    self[:CO_CNES] = value
  end

  # Configures an alias getter for the CO_CNES database column
  def cnes
    self[:CO_CNES]
  end

  # Configures an alias setter for the CO_USUARIO_EMPRESA database column
  def company_user_id=(value)
    self[:CO_USUARIO_EMPRESA] = value
  end

  # Configures an alias getter for the CO_USUARIO_EMPRESA database column
  def company_user_id
    self[:CO_USUARIO_EMPRESA]
  end

  # Configures an alias setter for the CO_USUARIO_UNIDADE database column
  def unity_user_id=(value)
    self[:CO_USUARIO_UNIDADE] = value
  end

  # Configures an alias getter for the CO_USUARIO_UNIDADE database column
  def unity_user_id
    self[:CO_USUARIO_UNIDADE]
  end

  # Configures an alias setter for the CO_USUARIO_CIDADE database column
  def city_user_id=(value)
    self[:CO_USUARIO_CIDADE] = value
  end

  # Configures an alias getter for the CO_USUARIO_CIDADE database column
  def city_user_id
    self[:CO_USUARIO_CIDADE]
  end

  # Configures an alias setter for the CO_CRIADO_POR database column
  def creator_id=(value)
    self[:CO_CRIADO_POR] = value
  end

  # Configures an alias getter for the CO_CRIADO_POR database column
  def creator_id
    self[:CO_CRIADO_POR]
  end

  # Configures an alias setter for the CO_CATEGORIA database column
  def category_id=(value)
    self[:CO_CATEGORIA] = value
  end

  # Configures an alias getter for the CO_CATEGORIA database column
  def category_id
    self[:CO_CATEGORIA]
  end

  # Configures an alias setter for the NU_COMPLEXIDADE database column
  def complexity=(value)
    self[:NU_COMPLEXIDADE] = value
  end

  # Configures an alias getter for the NU_COMPLEXIDADE database column
  def complexity
    self[:NU_COMPLEXIDADE]
  end

  # Configures an alias setter for the DT_CRIADO_EM database column
  def created_at=(value)
    self[:DT_CRIADO_EM] = value
  end

  # Configures an alias getter for the DT_CRIADO_EM database column
  def created_at
    self[:DT_CRIADO_EM]
  end

  # Configures an alias setter for the CO_SUPORTE database column
  def support_1_user_id=(value)
    self[:CO_SUPORTE] = value
  end

  # Configures an alias getter for the CO_SUPORTE database column
  def support_1_user_id
    self[:CO_SUPORTE]
  end

  # Configures an alias setter for the CO_SUPORTE_ADICIONAL database column
  def support_2_user_id=(value)
    self[:CO_SUPORTE_ADICIONAL] = value
  end

  # Configures an alias getter for the CO_SUPORTE_ADICIONAL database column
  def support_2_user_id
    self[:CO_SUPORTE_ADICIONAL]
  end

  # Retrieve all replies linked to Controversy, sorted by creation date
  def replies_sorted
    replies.order(DT_CRIADO_EM: :DESC)
  end

  # Returns all Controversy instances which are related to
  # the Company instance with <tt>sei</tt> equal as
  # the one passed as a paremter
  def self.from_company(sei)
    where(CO_SEI: sei)
  end

  # Returns all Controversy instances which are related to
  # the User instance with <tt>id</tt> equal as
  # the one passed as a paremter, through the
  # <tt>company_user</tt> relation
  def self.from_company_user(id)
    where(CO_USUARIO_EMPRESA: id)
  end

  # Returns all Controversy instances which are related to
  # the User instance with <tt>id</tt> equal as
  # the one passed as a paremter, through the
  # <tt>support_user</tt> relation
  def self.from_support_user(id)
    where('"CO_SUPORTE" = :id OR "CO_SUPORTE_ADICIONAL" = :id', id: "%#{id}%")
  end

  # Returns all Controversy instances which are related to
  # the City instance with <tt>id</tt> equal as
  # the one passed as a parameter
  def self.from_city(id)
    where(CO_CIDADE: id)
  end

  # Returns all Controversy instances which are related to
  # the User instance with <tt>id</tt> equal as
  # the one passed as a paremter, through the
  # <tt>unity_user</tt> relation
  def self.from_unity_user(id)
    where(CO_USUARIO_UNIDADE: id)
  end

  # Method which returns all the User instances who which participating in the Controversy
  def all_users
    [company_user,
     unity_user,
     city_user,
     support_1,
     support_2].reject(&:nil?)
  end

  # Method which returns all the User instances which are participating in the Controversy,
  # excluding the support ones
  def involved_users
    [company_user, unity_user, city_user].reject(&:nil?)
  end

  # Returns all the Controversy instances where the User instance with <tt>id</tt>
  # equal to the passed as parameters is related with the Controversy through the
  # <tt>company_id</tt> field
  def self.for_company_user(id)
    where(CO_USUARIO_EMPRESA: id)
  end

  # Returns all the Controversy instances where the User instance with <tt>id</tt>
  # equal to the passed as parameters is related with the Controversy through the
  # <tt>city_id</tt> field
  def self.for_city_user(id)
    where(CO_USUARIO_CIDADE: id)
  end

  # Returns all the Controversy instances where the User instance with <tt>id</tt>
  # equal to the passed as parameters is related with the Controversy through the
  # <tt>unity_id</tt> field
  def self.for_unity_user(id)
    where(CO_USUARIO_UNIDADE: id)
  end

  # Returns all the Controversy instances where the User instance with <tt>id</tt>
  # equal to the passed as parameters is related with the Controversy through the
  # <tt>support_1_user_id</tt> field
  def self.for_support_user(id)
    where(CO_SUPORTE: id)
  end

  # Returns all the Controversy instances where the Controversy instance with <tt>sei</tt>
  # equal to the passed as parameters is related with this Controversy
  def self.for_company(sei)
    where(CO_SEI: sei)
  end

  # This is a little mapping
  # to handle which field should be filled when creating
  # a Controversy
  def self.map_role_to_creator(user_id)
    role = User.find(user_id).role.to_sym

    {
      company_user: 'company',
      company_admin: 'company',
      ubs_admin: 'unity',
      ubs_user: 'unity',
      city_admin: 'city',
      call_center_admin: 'support_1',
      call_center_user: 'support_1',
      admin: 'support_1'
    }[role]
  end

  # Filterrific method
  #
  # Configures the possible filterrific sorting methods
  # to be acessed on ControversiesController
  def self.options_for_sorted_by_creation
    [
      ['Mais recentes', 'creation_desc'],
      ['Mais antigos', 'creation_asc']
    ]
  end

  # Filterrific method
  #
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

  #### FILTERRIFIC queries ####
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

    where('"DS_TITULO" ILIKE :search OR "DS_DESCRICAO" ILIKE :search', search: "%#{query}%")
  }

  scope :sorted_by_creation, lambda { |sort_key|
    sort = /asc$/.match?(sort_key) ? 'asc' : 'desc'

    case sort_key.to_s
    when /^creation_/
      order(CO_PROTOCOLO: sort)
    else
      raise(ArgumentError, 'Opção de filtro inválida')
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

  scope :with_ubs, ->(cnes) { cnes == [''] ? nil : where(CO_CNES: cnes) }

  scope :with_company, ->(sei) { sei == [''] ? nil : where(CO_SEI: sei) }

  scope :with_state, ->(state) { state == [''] ? nil : where(city: State.find(state).cities) }

  scope :with_city, ->(city_id) { city_id.zero? ? nil : where(city: city_id) }

  protected

  # Generate the Controversy protocol
  def generate_protocol
    self.protocol = 0.seconds.from_now.strftime('%Y%m%d%H%M%S%L').to_i
  end
end
