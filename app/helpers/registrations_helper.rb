# frozen_string_literal: true

module RegistrationsHelper
  def map_user_roles
    User.roles.keys.map { |role| [role.titleize, role] }
  end
end
