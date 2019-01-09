json.extract! @company, :sei

json.users do
  json.array! @company.users, :id, :name, :last_name, :last_sign_in_at
end

json.contracts do
  json.array! @company.contracts, :id, :city_id, :sei
end
