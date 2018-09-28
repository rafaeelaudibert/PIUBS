# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :company, class_name: 'Company', foreign_key: :sei, optional: true
  belongs_to :unity, class_name: 'Unity', foreign_key: :cnes, optional: true
  belongs_to :city, class_name: 'City', foreign_key: :id, optional: true
  has_many :calls
  has_many :answer

  enum role: %i[admin city_admin city_user ubs_admin ubs_user company_admin company_user call_center_admin call_center_user]
  validates_cpf_format_of :cpf, options: { allow_blank: true, allow_nil: true }
  validates :cpf, presence: true, uniqueness: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
