class RoleSkillSerializer < ActiveModel::Serializer
  belongs_to :role, serializer: RoleSerializerWithoutIncludes
  belongs_to :skill, serializer: SkillSerializerWithoutIncludes
end
