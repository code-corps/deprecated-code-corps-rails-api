class UserSerializerWithoutIncludes < ActiveModel::Serializer
  attributes :id, :email, :name, :username, :twitter, :biography, :website
end
