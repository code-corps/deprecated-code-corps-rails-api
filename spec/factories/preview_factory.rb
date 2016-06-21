# == Schema Information
#
# Table name: previews
#
#  id         :integer          not null, primary key
#  body       :text             not null
#  markdown   :text             not null
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :preview do
    sequence(:markdown) { |n| "Post content #{n}" }

    association :user
  end
end
