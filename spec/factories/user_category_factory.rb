FactoryGirl.define do
  factory :user_category do
    association :user
    association :category
  end
end
