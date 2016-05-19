class RoleSerializerWithoutIncludes < ActiveModel::Serializer
  attributes :id, :name, :ability
end
