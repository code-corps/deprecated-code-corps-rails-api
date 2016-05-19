# == Schema Information
#
# Table name: comment_user_mentions
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  comment_id  :integer          not null
#  post_id     :integer          not null
#  username    :string           not null
#  start_index :integer          not null
#  end_index   :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  status      :string           default("preview"), not null
#

FactoryGirl.define do

  factory :comment_user_mention do
    association :user
    association :comment
    association :post

    sequence(:start_index) { |n| n }
    sequence(:end_index) { |n| n }
  end

end
