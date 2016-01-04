FactoryGirl.define do

  factory :skill do
    sequence(:title) { |n| "Skill #{n}" }
    sequence(:description) { |n| "Skill description #{n}" }

    association :skill_category
  end

end
