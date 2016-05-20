class ProjectSkillSerializer < ActiveModel::Serializer
  belongs_to :project, serializer: ProjectSerializerWithoutIncludes
  belongs_to :skill, serializer: SkillSerializerWithoutIncludes
end
