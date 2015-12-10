FactoryGirl.define do

  factory :post do
    sequence(:title) { |n| "Post #{n}" }
    sequence(:markdown) { |n| "Post markdown #{n}" }

    association :user
    association :project

    trait :published do
      after :create do |post, evaluator|
        post.publish!
      end
    end
  end

end
