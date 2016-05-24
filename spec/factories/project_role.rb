FactoryGirl.define do
  factory :project_role do
    association :project
    association :role
  end
end
