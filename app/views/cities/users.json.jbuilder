json.array! @users do |user|
  json.extract! user, :name, :last_name, :email, :city_id
end
