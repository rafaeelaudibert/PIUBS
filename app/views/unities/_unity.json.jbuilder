# frozen_string_literal: true

json.extract! unity, :id, :cnes, :name, :city_id, :created_at, :updated_at
json.url unity_url(unity, format: :json)
