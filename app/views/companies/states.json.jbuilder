json.array! @states do |state|
  json.extract! state, :abbr, :id, :name
end
