# == Schema Information
#
# Table name: post_likes
#
#  id         :integer          not null, primary key
#  post_id    :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do

  factory :post_like do
    after(:build) do |post, evaluator|
      post.user = evaluator.user || build(:user)
      post.post = evaluator.post || build(:post)
    end
  end

end
