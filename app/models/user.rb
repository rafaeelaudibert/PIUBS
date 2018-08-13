class User < ApplicationRecord
  belongs_to :company, class_name: "Company", foreign_key: :sei, optional: true
  enum role: [:admin, :city_admin, :city_user, :ubs_admin, :ubs_user, :company_admin, :company_user, :call_center_admin, :call_center_user]
  after_initialize :set_default_role, :if => :new_record?
  cattr_accessor :user_logged
  attr_accessible :user

  def set_default_role
    puts $current_user_role

    # temp -> new user invitation with current user role
    self.role ||= $current_user_role
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
end
