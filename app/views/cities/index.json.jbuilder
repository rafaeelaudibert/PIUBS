# frozen_string_literal: true

json.array! @cities do |city|
  json.extract! city, :id, :name, :state_id
end
