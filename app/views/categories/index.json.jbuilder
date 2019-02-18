# frozen_string_literal: true

json.array! @categories do |category|
  json.extract! category, :id, :name, :parsed_source, :severity, :parent_id
end
