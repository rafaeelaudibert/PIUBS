json.array! @users do |user|
  json.extract! user, :name, :last_name, :fullname, :email, :cnes
end
