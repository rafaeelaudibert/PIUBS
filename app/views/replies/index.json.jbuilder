# frozen_string_literal: true

json.array! @replies, partial: 'replies/reply', as: :reply
