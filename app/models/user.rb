class User < ApplicationRecord
  belongs_to :company
  enum role: [:admin, :city_admin, :city_user, :ubs_admin, :ubs_user, :company_admin, :company_user, :call_center_admin, :call_center_user]
  after_initialize :set_default_role, :if => :new_record?

  def set_default_role
    self.role ||= :admin
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
end
