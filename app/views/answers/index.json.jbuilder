# frozen_string_literal: true

json.array! @answers, partial: 'answers/answer', as: :answer
