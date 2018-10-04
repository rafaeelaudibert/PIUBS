# frozen_string_literal: true

json.extract! call, :id, :title, :description, :finished_at, :status, :version, :access_profile, :feature_detail, :answer_summary, :severity, :protocol, :city_id, :category_id, :state_id, :company_id, :created_at, :updated_at
json.url call_url(call, format: :json)
