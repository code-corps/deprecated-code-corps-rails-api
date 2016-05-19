FactoryGirl.define do
  factory :project_category do
    association :project
    association :category
  end
end
