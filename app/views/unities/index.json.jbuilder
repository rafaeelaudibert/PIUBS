json.array! @unities do |unity|
  json.extract! unity, :cnes, :name, :city_id, :address, :neighborhood, :phone
end
