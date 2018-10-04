# frozen_string_literal: true

json.extract! attachment, :id, :filename, :content_type, :file_contents,
              :answer_id, :created_at, :updated_at
json.url attachment_url(attachment, format: :json)
