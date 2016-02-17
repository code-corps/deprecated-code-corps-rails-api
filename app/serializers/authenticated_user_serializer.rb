class AuthenticatedUserSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :username, :twitter, :biography, :website,
             :photo_thumb_url, :photo_large_url

  def photo_thumb_url
    object.photo.url(:thumb)
  end

  def photo_large_url
    object.photo.url(:large)
  end
end
