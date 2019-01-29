# frozen_string_literal: true

json.array! @states do |state|
  json.extract! state, :abbr, :id, :name
end
