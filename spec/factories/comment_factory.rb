# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  body             :text
#  user_id          :integer          not null
#  post_id          :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  markdown         :text
#  aasm_state       :string
#  body_preview     :text
#  markdown_preview :text
#

FactoryGirl.define do

  factory :comment do
    sequence(:markdown) { |n| "Comment #{n}" }

    association :post
    association :user

    transient do
      mention_count 5
    end

    trait :with_user_mentions do
      after :create do |comment, evaluator|
        create_list(:comment_user_mention, evaluator.mention_count, comment: comment)
      end
    end
  end

end
