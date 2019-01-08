json.array! @states do |state|
  json.extract! state, :id, :name, :abbr
end
