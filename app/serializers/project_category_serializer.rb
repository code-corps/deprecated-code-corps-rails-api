# == Schema Information
#
# Table name: project_categories
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  category_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ProjectCategorySerializer < ActiveModel::Serializer
  belongs_to :project, serializer: ProjectSerializerWithoutIncludes
  belongs_to :category
end
