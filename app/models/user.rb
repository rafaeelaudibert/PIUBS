# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :company, class_name: 'Company', foreign_key: :sei, optional: true
  belongs_to :unity, class_name: 'Unity', foreign_key: :cnes, optional: true
  belongs_to :city, class_name: 'City', foreign_key: :id, optional: true
  has_many :calls
  has_many :answer

  enum role: %i[admin city_admin faq_inserter
                ubs_admin ubs_user
                company_admin company_user
                call_center_admin call_center_user]
  validates_cpf_format_of :cpf, options: { allow_blank: true, allow_nil: true }
  validates :cpf, presence: true, uniqueness: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :async

   filterrific(
    default_filter_params: { sorted_by_name: 'name_asc'},
    available_filters: [
      :sorted_by_name,
      :with_role,
      :with_status_adm,
      :with_status,
      :with_company,
      :with_state,
      :with_city,
      :search_query
    ]
  )

  scope :search_query, lambda { |query|
    return nil  if query.blank?
    query_search = "%#{query}%"
    where("name ILIKE :search OR last_name ILIKE :search OR email ILIKE :search", search: query_search)
  }

  scope :sorted_by_name, lambda { |sort_key|
    sort = (sort_key =~ /asc$/) ? 'asc' : 'desc'
    case sort_key.to_s
    when /^name_/
      order(name: sort)
    else
      raise(ArgumentError, "Invalid filter option")
    end
  }

  scope :with_role, lambda { |role|
    return nil if role == [""]
      if role != [""]
        where(role: role)
      end
  }

  scope :with_status_adm, lambda { |status|
    if status == "" || status == "all"
      return nil
    elsif status == "registered"
      where("invitation_accepted_at IS NOT NULL")
    elsif status == "invited"
      where("invitation_sent_at IS NOT NULL AND invitation_accepted_at IS NULL")
    elsif status == "bot"
      where("invitation_sent_at IS NULL AND invitation_accepted_at IS NULL")
    end
  }

  scope :with_status, lambda { |status|
    return nil if status == [""]
      if status == ["registered"]
        where("invitation_accepted_at" != nil)
      elsif status == ["invited"]
        where("invitation_sent_at" != nil)
      end
  }

  scope :with_city, lambda { |city|
    unless (city == 0)
      where(city_id: city)
    end
  }

  scope :with_company, lambda { |sei|
    unless (sei == "")
      where(sei: sei)
    end
  }

  def self.options_for_with_status
    [
      ['Cadastrados', 'registered'],
      ['Convidados', 'invited'],
    ]
  end

  def self.options_for_with_status_adm
    [
      ['Cadastrados', 'registered'],
      ['Convidados', 'invited'],
      ['Robôs', 'bot'],
    ]
  end

  def self.options_for_sorted_by_name
    [
      ['Nome [A-Z]', 'name_asc'],
      ['Nome [Z-A]', 'name_desc'],
    ]
  end

  def self.options_for_with_role
    [
      ['Administradores', 0],
      ['FAQ', 2],
      ['Empresa [Usu]', 6],
      ['Empresa [Adm]', 5],
      ['Suporte [Usu]', 8],
      ['Suporte [Adm]', 7],
      ['Município', 1],
      ['UBS [Usu]', 4],
      ['UBS [Adm]', 3],
    ]
  end

  def self.options_for_with_city
    [
      ['Cidade', 0],
    ]
  end

  def self.admins
    User.where(role: :admin).order(:id)
  end

  def self.company_accounts
    User.where(role: [:company_admin, :company_user]).order(:id)
  end

  def self.support_accounts
    User.where(role: [:call_center_admin, :call_center_user]).order(:id)
  end

  def self.faq_inserters
    User.where(role: :faq_inserter).order(:id)
  end

  def self.city_accounts
    User.where(role: :city_admin).order(:id)
  end

  def self.unity_accounts
    User.where(role: [:ubs_admin, :ubs_user]).order(:id)
  end

  def self.by_role
    {
      'Admin'     => User.admins,
      'Company'   => User.company_accounts,
      'Support'   => User.support_accounts,
      'FAQ'       => User.faq_inserters,
      'City'      => User.city_accounts,
      'UBS'       => User.unity_accounts
    }
  end

  def self.send_devise_notification(notification, *args)
    DeviseWorker.perform_async(devise_mailer, notification, id, *args)
  end

end
