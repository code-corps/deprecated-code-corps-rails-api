class ProjectRoleSerializer < ActiveModel::Serializer
  belongs_to :project, serializer: ProjectSerializerWithoutIncludes
  belongs_to :role
end
