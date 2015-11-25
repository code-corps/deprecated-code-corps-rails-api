FactoryGirl.define do

  factory :post do
    sequence(:title) { |n| "Post #{n}" }
    association :user
    association :project
  end

end
