# frozen_string_literal: true

FactoryBot.define do
  factory :reply do
    protocol 'MyString'
    description 'MyText'
    user nil
  end
end
