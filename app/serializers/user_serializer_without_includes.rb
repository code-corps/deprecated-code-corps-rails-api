class UserSerializerWithoutIncludes < ActiveModel::Serializer
  attributes :id, :email, :name, :username, :twitter, :biography, :website,
             :facebook_id, :facebook_access_token, :photo_thumb_url,
             :photo_large_url, :state

  def photo_thumb_url
    object.photo.url(:thumb)
  end

  def photo_large_url
    object.photo.url(:large)
  end
end
