FactoryGirl.define do

  factory :post do
    sequence(:title) { |n| "Post #{n}" }
    sequence(:body) { |n| "Post body #{n}" }
    sequence(:markdown) { |n| "Post markdown #{n}" }

    association :user
    association :project
  end

end
