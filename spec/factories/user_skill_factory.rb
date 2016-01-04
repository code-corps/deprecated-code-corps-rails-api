FactoryGirl.define do

  factory :user_skill do
    association :user
    association :skill
  end

end
