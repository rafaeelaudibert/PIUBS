# frozen_string_literal: true

##
# User class which is controlled principally by Devise
class User < ApplicationRecord
  belongs_to :company, foreign_key: :CO_SEI, optional: true
  belongs_to :unity, foreign_key: :CO_CNES, optional: true
  belongs_to :city, foreign_key: :CO_CIDADE, optional: true
  has_many :calls, foreign_key: :CO_USUARIO
  has_many :answer, foreign_key: :CO_USUARIO
  validates_cpf_format_of :NU_CPF, options: { allow_blank: true, allow_nil: true }
  validates :NU_CPF, presence: true, uniqueness: true

  # If update here, update to en.yml
  alias_attribute :role, :TP_ROLE
  enum role: %i[admin city_admin faq_inserter
                ubs_admin ubs_user
                company_admin company_user
                call_center_admin call_center_user]

  # If update here, update to en.yml
  alias_attribute :system, :ST_SISTEMA
  enum system: %i[companies controversies both]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable, :async

  #### DATABASE adaptations ####
  self.table_name = :TB_USUARIO # Setting a different table_name

  # Configures an alias setter for the NO_NOME database column
  def name=(value)
    self[:NO_NOME] = value
  end

  # Configures an alias getter for the NO_NOME database column
  def name
    self[:NO_NOME]
  end

  # Configures an alias setter for the TP_ROLE database column
  def role=(value)
    self[:TP_ROLE] = value
  end

  # Configures an alias getter for the TP_ROLE database column
  def role
    self[:TP_ROLE]
  end

  # Configures an alias setter for the NU_CPF database column
  def cpf=(value)
    self[:NU_CPF] = value
  end

  # Configures an alias getter for the NU_CPF database column
  def cpf
    self[:NU_CPF]
  end

  # Configures an alias setter for the NO_SOBRENOME database column
  def last_name=(value)
    self[:NO_SOBRENOME] = value
  end

  # Configures an alias getter for the NO_SOBRENOME database column
  def last_name
    self[:NO_SOBRENOME]
  end

  # Configures an alias setter for the ST_SISTEMA database column
  def system=(value)
    self[:ST_SISTEMA] = value
  end

  # Configures an alias getter for the ST_SISTEMA database column
  def system
    self[:ST_SISTEMA]
  end

  # Configures an alias setter for the CO_CIDADE database column
  def city_id=(value)
    self[:CO_CIDADE] = value
  end

  # Configures an alias getter for the CO_CIDADE database column
  def city_id
    self[:CO_CIDADE]
  end

  # Configures an alias setter for the CO_SEI database column
  def sei=(value)
    self[:CO_SEI] = value
  end

  # Configures an alias getter for the CO_SEI database column
  def sei
    self[:CO_SEI]
  end

  # Configures an alias setter for the CO_CNES database column
  def cnes=(value)
    self[:CO_CNES] = value
  end

  # Configures an alias getter for the CO_CNES database column
  def cnes
    self[:CO_CNES]
  end

  #### FILTERRIFIC queries ####
  filterrific default_filter_params: { sorted_by_name: 'name_asc' },
              available_filters: %i[
                sorted_by_name
                with_role
                with_status_adm
                with_status
                with_company
                with_state
                with_city
                search_query
              ]

  scope :search_query, lambda { |query|
    return nil if query.blank?

    where('"NO_NOME" ILIKE :search OR "NO_SOBRENOME" ILIKE :search OR email ILIKE :search',
          search: "%#{query}%")
  }

  scope :sorted_by_name, lambda { |sort_key|
    sort = sort_key.match?(/asc$/) ? 'asc' : 'desc'

    case sort_key.to_s
    when /^name_/
      order(NO_NOME: sort)
    else
      raise(ArgumentError, 'Invalid filter option')
    end
  }

  scope :with_role, ->(role) { role == [''] ? nil : where(TP_ROLE: role) }

  scope :with_status_adm, lambda { |status|
    return nil if ['', 'all'].include? status

    if status == 'registered'
      where('invitation_accepted_at IS NOT NULL')
    elsif status == 'invited'
      where('invitation_sent_at IS NOT NULL AND invitation_accepted_at IS NULL')
    elsif status == 'bot'
      where('invitation_sent_at IS NULL AND invitation_accepted_at IS NULL')
    end
  }

  scope :with_status, lambda { |status|
    return nil if status == ['']

    if status == ['registered']
      where(!'invitation_accepted_at'.nil?)
    elsif status == ['invited']
      where(!'invitation_sent_at'.nil?)
    end
  }

  scope :with_state, lambda { |state|
    cities = City.where(CO_UF: state).map(&:CO_CODIGO)
    unities = Unity.where(CO_CIDADE: cities).map(&:CO_CNES)
    companies = Contract.where(CO_CIDADE: cities).map(&:CO_SEI).uniq!
    return [] if state == ['']

    where('"CO_CNES" IN (?) OR "CO_SEI" IN (?)', unities, companies)
  }

  scope :with_city, lambda { |city|
    sei = Contract.where(CO_CIDADE: city).map(&:CO_SEI).uniq!
    where('"CO_CIDADE" = ? OR "CO_SEI" IN (?)', city, sei) unless city.zero?
  }

  scope :with_company, ->(sei) { sei == '' ? nil : where(CO_SEI: sei) }

  # Filterrific options when sorting by status
  def self.options_for_with_status
    [
      %w[Cadastrados registered],
      %w[Convidados invited]
    ]
  end

  # Filterrific options when sorting by status in an admin view
  def self.options_for_with_status_adm
    [
      %w[Cadastrados registered],
      %w[Convidados invited],
      %w[Robôs bot]
    ]
  end

  # Filterrific options when sorting by name
  def self.options_for_sorted_by_name
    [
      ['Nome [A-Z]', 'name_asc'],
      ['Nome [Z-A]', 'name_desc']
    ]
  end

  # Filterrific options when sorting by role
  def self.options_for_with_role
    [
      ['Administradores', 0],
      ['Município', 1],
      ['FAQ', 2],
      ['UBS [Adm]', 3],
      ['UBS [Usu]', 4],
      ['Empresa [Adm]', 5],
      ['Empresa [Usu]', 6],
      ['Suporte [Adm]', 7],
      ['Suporte [Usu]', 8]
    ]
  end

  # Filterrific options when sorting by city
  def self.options_for_with_city
    [
      ['Cidade', 0]
    ]
  end

  # Returns all the users which have the role :admin
  def self.admins
    User.where(role: :admin)
  end

  # Returns all the users which belong to a company,
  # this is, have a role which is :company_admin or :company_user
  def self.company_accounts
    User.where(role: %i[company_admin company_user])
  end

  # Returns all the users which belong to the support,
  # this is, have a role which is :call_center_admin or :call_center_user
  def self.support_accounts
    User.where(role: %i[call_center_admin call_center_user])
  end

  # Returns all the users which have the role :faq_inserter
  def self.faq_inserters
    User.where(role: :faq_inserter)
  end

  # Returns all the users which belong to a city,
  # this is, have a role :city_admin
  def self.city_accounts
    User.where(role: :city_admin)
  end

  # Returns all the users which belong to the unities,
  # this is, have a role which is :ubs_admin or :ubs_user
  def self.unity_accounts
    User.where(role: %i[ubs_admin ubs_user])
  end

  # Returns all the users from the database,
  # but ordered in a hash according to its role
  def self.by_role
    {
      'Admin' => User.admins,
      'Company' => User.company_accounts,
      'Support' => User.support_accounts,
      'FAQ' => User.faq_inserters,
      'City' => User.city_accounts,
      'UBS' => User.unity_accounts
    }
  end

  # Returns all the users which belongs
  # to the City passed in the parameter
  def self.from_city(city_id)
    User.where(CO_CIDADE: city_id, CO_CNES: nil)
  end

  # Returns all the users which belongs
  # to the Unity passed in the parameter
  def self.from_ubs(cnes)
    User.where(CO_CNES: cnes)
  end

  # Returns all the users which belongs
  # to the Company passed in the parameter
  def self.from_company(sei)
    User.where(CO_SEI: sei)
  end

  # Returns all the users which match
  # their name or their CPF to the passed parameter
  def self.find_with_term(terms)
    where('"NO_NOME" ILIKE ? OR "NU_CPF" ILIKE ? or email ILIKE ?',
          "%#{terms}%",
          "%#{terms}%",
          "%#{terms}%")
  end

  # Returns all the users except the one passed as parameter
  def self.except(id)
    where.not(id: id)
  end

  # Returns all the users which were invited by the User
  # with the id passed as parameter
  def self.invited_by(id)
    where(invited_by_id: id)
  end

  # Returns the user fullname concatenating his first and last name
  def fullname
    "#{name} #{last_name}"
  end

  # Overrides Devise function
  #
  # This way we can manipulate the devise e-mails layout properly, as well as
  # making it asynchronous
  def self.send_devise_notification(notification, *args)
    DeviseWorker.perform_async(devise_mailer, notification, id, *args)
  end
end
