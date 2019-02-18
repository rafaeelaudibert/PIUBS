# frozen_string_literal: true

json.array! @unities do |unity|
  json.extract! unity, :name, :cnes
end
