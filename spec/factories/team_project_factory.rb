FactoryGirl.define do

  factory :team_project do
    association :team
    association :project
  end

end
