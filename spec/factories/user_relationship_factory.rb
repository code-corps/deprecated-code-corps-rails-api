# == Schema Information
#
# Table name: user_relationships
#
#  id           :integer          not null, primary key
#  follower_id  :integer
#  following_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do
  factory :user_relationship do |f|
  end
end
