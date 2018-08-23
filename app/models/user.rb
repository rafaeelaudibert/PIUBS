class User < ApplicationRecord

  belongs_to :company, class_name: "Company", foreign_key: :sei, optional: true
  has_many :calls
  has_many :answer
  enum role: [:admin, :city_admin, :city_user, :ubs_admin, :ubs_user, :company_admin, :company_user, :call_center_admin, :call_center_user]
  after_initialize :set_levels_allowed, :set_default_role, :if => :new_record?

  # Levels for new users invitateds by specific users
  def set_levels_allowed
    if $current_user_role == 'admin'
      $levels_allowed = [:admin, :city_admin, :ubs_admin, :company_admin, :call_center_admin]
    else
      if $current_user_role == 'city_admin'
        $selected_role = :ubs_admin
      else
        if $current_user_role == 'ubs_admin'
          $selected_role = :ubs_user
        else
          if $current_user_role == 'company_admin'
            $selected_role = :company_user
          else
            if $current_user_role == 'call_center_admin'
              $selected_role = :call_center_user
            else
              $levels_allowed = []
            end
          end
        end
      end
    end
  end

  def set_default_role
    self.role ||= $selected_role
    self.sei ||= $current_user_sei
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
