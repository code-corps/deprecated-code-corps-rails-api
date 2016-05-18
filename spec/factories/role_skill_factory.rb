FactoryGirl.define do
  factory :role_skill do
    association :role
    association :skill
  end
end
