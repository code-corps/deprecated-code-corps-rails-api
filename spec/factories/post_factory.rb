# == Schema Information
#
# Table name: posts
#
#  id               :integer          not null, primary key
#  status           :string           default("open")
#  post_type        :string           default("task")
#  title            :string           not null
#  body             :text             not null
#  user_id          :integer          not null
#  project_id       :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  post_likes_count :integer          default(0)
#  markdown         :text             not null
#  number           :integer
#  aasm_state       :string
#

FactoryGirl.define do

  factory :post do
    sequence(:title) { |n| "Post #{n}" }
    sequence(:markdown) { |n| "Post markdown #{n}" }
    sequence(:number) { |n| n }

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
