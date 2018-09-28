# frozen_string_literal: true

FactoryBot.define do
  factory :call do
    title 'MyString'
    description 'MyText'
    finished_at '2018-08-09 08:44:49'
    status 1
    version 'MyString'
    access_profile 'MyString'
    feature_detail 'MyString'
    answer_summary 'MyString'
    severity 'MyString'
    protocol 'MyString'
    city nil
    category nil
    state nil
    company nil
  end
end
