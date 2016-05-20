FactoryGirl.define do
  factory :interest do
    association :user
    association :category
  end
end
