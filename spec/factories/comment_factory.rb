FactoryGirl.define do

  factory :comment do
    sequence(:markdown) { |n| "Comment #{n}" }

    association :post
    association :user
  end

end
