class User < ApplicationRecord
  belongs_to :company, class_name: "Company", foreign_key: :sei, optional: true
  enum role: [:admin, :city_admin, :city_user, :ubs_admin, :ubs_user, :company_admin, :company_user, :call_center_admin, :call_center_user]
  after_initialize :set_default_role, :set_levels_allowed, :if => :new_record?

  # Levels for new users invitateds by specific users
  def set_levels_allowed
    if $current_user_role == 'admin'
      $levels_allowed = [:admin, :city_admin, :ubs_admin, :company_admin, :call_center_admin]
    else
      if $current_user_role == 'city_admin'
        $levels_allowed = [:ubs_admin]
      else
        if $current_user_role == 'ubs_admin'
          $levels_allowed = [:ubs_user]
        else
          if $current_user_role == 'company_admin'
            $levels_allowed = [:company_user]
          else
            if $current_user_role == 'call_center_admin'
              $levels_allowed = [:call_center_user]
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
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
end
