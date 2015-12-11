FactoryGirl.define do

  factory :post do
    sequence(:title) { |n| "Post #{n}" }
    sequence(:markdown) { |n| "Post markdown #{n}" }

    association :user
    association :project

    transient do
      mention_count 5
    end

    trait :published do
      after :create do |post, evaluator|
        post.publish!
      end
    end

    trait :with_user_mentions do
      after :create do |post, evaluator|
        create_list(:post_user_mention, evaluator.mention_count, post: post)
      end
    end
  end

end
