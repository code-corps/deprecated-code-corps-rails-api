class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :username, :twitter, :biography, :website, :facebook_id, :facebook_access_token

  has_many :skills
end
