class UserSerializerWithoutIncludes < ActiveModel::Serializer
  attributes :id, :email, :username, :twitter, :biography, :website
end
