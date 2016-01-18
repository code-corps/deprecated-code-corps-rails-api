# == Schema Information
#
# Table name: user_skills
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  skill_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do

  factory :user_skill do
    association :user
    association :skill
  end

end
