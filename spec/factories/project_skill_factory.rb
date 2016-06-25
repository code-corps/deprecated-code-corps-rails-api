# == Schema Information
#
# Table name: project_skills
#
#  id         :integer          not null, primary key
#  project_id :integer
#  skill_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :project_skill do
    association :project
    association :skill
  end
end
