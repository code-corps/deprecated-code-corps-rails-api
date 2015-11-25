FactoryGirl.define do

  factory :comment do
    sequence(:body) { |n| "Comment #{n}" }

    association :post
  end

end
