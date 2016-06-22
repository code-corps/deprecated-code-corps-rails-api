# == Schema Information
#
# Table name: users
#
#  id                    :integer          not null, primary key
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  email                 :string           not null
#  encrypted_password    :string(128)      not null
#  confirmation_token    :string(128)
#  remember_token        :string(128)      not null
#  username              :string
#  admin                 :boolean          default(FALSE), not null
#  website               :text
#  twitter               :string
#  biography             :text
#  facebook_id           :string
#  facebook_access_token :string
#  base64_photo_data     :string
#  photo_file_name       :string
#  photo_content_type    :string
#  photo_file_size       :integer
#  photo_updated_at      :datetime
#  name                  :text
#  aasm_state            :string           default("signed_up"), not null
#

class UserSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :email, :name, :username, :twitter, :biography, :website,
             :facebook_id, :facebook_access_token, :photo_thumb_url,
             :photo_large_url, :state

  has_many :categories
  has_many :user_categories
  has_many :organizations
  has_many :organization_memberships
  has_many :roles
  has_many :user_roles
  has_many :skills

  def photo_thumb_url
    object.photo.url(:thumb)
  end

  def photo_large_url
    object.photo.url(:large)
  end
end
