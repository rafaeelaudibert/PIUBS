# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    confirmed_at 0.seconds.from_now
    name 'Test User'
    email 'test@example.com'
    password 'please123'

    trait :admin do
      role 'admin'
    end
  end
end
