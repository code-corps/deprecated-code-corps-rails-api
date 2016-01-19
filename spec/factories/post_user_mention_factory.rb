# == Schema Information
#
# Table name: post_user_mentions
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  post_id     :integer          not null
#  username    :string           not null
#  start_index :integer          not null
#  end_index   :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do

  factory :post_user_mention do
    association :user
    association :post

    sequence(:start_index) { |n| n }
    sequence(:end_index) { |n| n }
  end

end
