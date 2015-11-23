class AuthenticatedUserSerializer < ActiveModel::Serializer
  attributes :id, :email, :username
end
