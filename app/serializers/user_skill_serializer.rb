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

class UserSkillSerializer < ActiveModel::Serializer
  belongs_to :user
  belongs_to :skill
end
