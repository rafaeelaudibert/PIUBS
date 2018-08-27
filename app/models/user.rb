class User < ApplicationRecord
  belongs_to :company, class_name: "Company", foreign_key: :sei, optional: true
  belongs_to :unity, class_name: "Unity", foreign_key: :cnes, optional: true
  belongs_to :city, class_name: "City", foreign_key: :id, optional: true
  has_many :calls
  has_many :answer
  enum role: [:admin, :city_admin, :city_user, :ubs_admin, :ubs_user, :company_admin, :company_user, :call_center_admin, :call_center_user]
  after_initialize :set_default_role, :if => :new_record?

  def set_default_role
    self.sei = $user_sei
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
