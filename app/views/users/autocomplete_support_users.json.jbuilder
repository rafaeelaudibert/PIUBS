json.array! @users do |user|
  json.id user.id
  json.support_user_id user.id
  json.label "#{user.name} - #{user.cpf}"
  json.value user.name
end
