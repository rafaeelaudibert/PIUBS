# frozen_string_literal: true

json.array! @users do |user|
  json.extract! user, :name, :last_name, :fullname, :email, :city_id
end
