class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :username, :twitter, :biography, :website, :facebook_id, :facebook_access_token, :photo_thumb_url, :photo_large_url

  has_many :skills

  def photo_thumb_url
    object.photo.url(:thumb)
  end

  def photo_large_url
    object.photo.url(:large)
  end
end
