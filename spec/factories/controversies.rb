# frozen_string_literal: true

FactoryBot.define do
  factory :controversy do
    title { 'MyString' }
    description { 'MyString' }
    protocol { 'MyString' }
    closed_at { '2018-10-24 16:27:10' }
    company_id { 1 }
    contract_id { 1 }
    city_id { 1 }
    unity_id { 1 }
    company_user_id { 1 }
    unity_user_id { 1 }
    creator { 1 }
    category { 1 }
    complexity { 1 }
    support_1_id { 1 }
    support_2_id { 1 }
  end
end
