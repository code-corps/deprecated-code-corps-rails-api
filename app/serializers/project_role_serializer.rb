# == Schema Information
#
# Table name: project_roles
#
#  id         :integer          not null, primary key
#  project_id :integer
#  role_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProjectRoleSerializer < ActiveModel::Serializer
  belongs_to :project, serializer: ProjectSerializerWithoutIncludes
  belongs_to :role, serializer: RoleSerializerWithoutIncludes
end
