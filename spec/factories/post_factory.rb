# == Schema Information
#
# Table name: posts
#
#  id               :integer          not null, primary key
#  status           :string           default("open")
#  post_type        :string           default("task")
#  title            :string
#  body             :text
#  user_id          :integer          not null
#  project_id       :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  post_likes_count :integer          default(0)
#  markdown         :text
#  number           :integer
#  aasm_state       :string
#  comments_count   :integer          default(0)
#

FactoryGirl.define do
  factory :post do
    sequence(:title) { |n| "Post #{n}" }
    sequence(:markdown) { |n| "Post content #{n}" }

    association :user
    association :project

    trait :published do
      aasm_state :published
      markdown "Post content"
      body "Post content"
    end

    trait :edited do
      aasm_state :edited
      markdown "Post content"
      body "Post content"
    end

    trait :with_user_mentions do
      transient do
        mention_count 5
      end

      after :create do |post, evaluator|
        create_list(:post_user_mention, evaluator.mention_count, post: post)
      end
    end

    trait :with_number do
      sequence(:number) { |n| n }
    end
  end
end
