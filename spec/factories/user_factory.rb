FactoryGirl.define do

  factory :user do |user|
    sequence(:email) { |n| "test#{n}@tester.com" }
    sequence(:username) { |n| "tester#{n}" }
    password "password"
  end

end