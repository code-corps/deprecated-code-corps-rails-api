class ProjectCategorySerializer < ActiveModel::Serializer
  belongs_to :project, serializer: ProjectSerializerWithoutIncludes
  belongs_to :category
end
