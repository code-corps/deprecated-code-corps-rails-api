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
#  body_preview     :text
#  markdown_preview :text
#

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

    trait :with_number do
      sequence(:number) { |n| n }
    end
  end

end
