# frozen_string_literal: true

json.extract! @company, :sei, :name, :cnpj

json.users do
  json.array! @company.users, :id, :name, :last_name, :fullname, :last_sign_in_at
end

json.contracts do
  json.array! @company.contracts, :id, :city_id, :sei
end
