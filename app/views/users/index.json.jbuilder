json.array! @users do |user|
  json.extract! user, :id, :name, :last_name, :cpf, :email, :role, :city_id,
                :sei, :cnes, :last_sign_in_at
end
