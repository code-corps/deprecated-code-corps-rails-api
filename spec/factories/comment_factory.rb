FactoryGirl.define do

  factory :comment do
    sequence(:body) { |n| "Comment #{n}" }

    association :post
    association :user
  end

end
