class User < ApplicationRecord
  belongs_to :company, class_name: "Company", foreign_key: :sei, optional: true
  enum role: [:admin, :city_admin, :city_user, :ubs_admin, :ubs_user, :company_admin, :company_user, :call_center_admin, :call_center_user]
  after_initialize :set_default_role, :set_permitted_roles_list, :if => :new_record?

  def set_permitted_roles_list
    if $current_user_role == 'admin'
      $permitteds = [:admin, :city_admin, :ubs_admin, :company_admin, :call_center_admin]
    else
      if $current_user_role == 'city_admin'
        $permitteds = [:ubs_admin]
      else
        if $current_user_role == 'ubs_admin'
          $permitteds = [:ubs_user]
        else
          if $current_user_role == 'company_admin'
            $permitteds = [:company_user]
          else
            if $current_user_role == 'call_center_admin'
              $permitteds = [:call_center_user]
            else
              $permitteds = []
            end
          end
        end
      end
    end
  end

  def set_default_role
    self.role ||= :admin
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
end
