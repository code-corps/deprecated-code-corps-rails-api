FactoryGirl.define do
  factory :project_skill do
    association :project
    association :skill
  end
end
