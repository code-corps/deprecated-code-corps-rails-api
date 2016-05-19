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

class RoleSkillSerializer < ActiveModel::Serializer
  belongs_to :role, serializer: RoleSerializerWithoutIncludes
  belongs_to :skill, serializer: SkillSerializerWithoutIncludes
end
