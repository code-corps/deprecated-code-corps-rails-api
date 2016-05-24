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

class ProjectSkillSerializer < ActiveModel::Serializer
  belongs_to :project, serializer: ProjectSerializerWithoutIncludes
  belongs_to :skill, serializer: SkillSerializerWithoutIncludes
end
