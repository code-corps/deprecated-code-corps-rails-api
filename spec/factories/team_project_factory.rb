FactoryGirl.define do

  factory :team_project do |f|
    association :team
    association :project
  end

end
