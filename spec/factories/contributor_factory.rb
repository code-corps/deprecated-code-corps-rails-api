FactoryGirl.define do

  factory :contributor do
    status "pending"

    association :project
    association :user
  end

end
