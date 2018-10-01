# frozen_string_literal: true

json.extract! company, :id, :sei, :created_at, :updated_at
json.url company_url(company, format: :json)
