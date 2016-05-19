# == Schema Information
#
# Table name: role_skills
#
#  id         :integer          not null, primary key
#  role_id    :integer
#  skill_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :role_skill do
    association :role
    association :skill
  end
end
