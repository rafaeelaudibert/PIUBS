module RegistrationsHelper
  def map_user_roles
    User.roles.keys.map {|role| [role.titleize,role]}
  end
end
