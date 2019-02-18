# frozen_string_literal: true

json.array! answers, :id, :question, :answer, :keywords, :category_id, :user_id,
            :created_at
