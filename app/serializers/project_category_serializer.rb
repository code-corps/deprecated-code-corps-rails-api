class ProjectCategorySerializer < ActiveModel::Serializer
  belongs_to :project
  belongs_to :category
end
