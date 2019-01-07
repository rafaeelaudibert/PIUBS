json.array! @answers do |answer|
  json.extract! answer, :id, :question, :answer
end
