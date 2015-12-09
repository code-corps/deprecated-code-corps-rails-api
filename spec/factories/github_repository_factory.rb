FactoryGirl.define do

  factory :github_repository do
    sequence(:owner_name) { |n| "owner#{n}" }
    sequence(:repository_name) { |n| "repository#{n}" }

    association :project
  end

end
