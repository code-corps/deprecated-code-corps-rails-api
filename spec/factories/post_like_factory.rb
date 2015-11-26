FactoryGirl.define do

  factory :post_like do
    association :user
    association :post
  end

end
