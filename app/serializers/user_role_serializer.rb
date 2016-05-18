class UserRoleSerializer < ActiveModel::Serializer
  belongs_to :user
  belongs_to :role, serializer: RoleSerializerWithoutIncludes
end
