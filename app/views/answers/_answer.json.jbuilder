# frozen_string_literal: true

json.extract! answer, :id, :category_id, :user_id, :created_at, :updated_at
json.url answer_url(answer, format: :json)
