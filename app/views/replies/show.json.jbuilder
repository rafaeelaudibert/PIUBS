# frozen_string_literal: true

json.extract! @reply, :id, :repliable_id, :repliable_type,
              :description, :user_id, :created_at
