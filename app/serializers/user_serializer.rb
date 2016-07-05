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
#  aasm_state            :string           default("signed_up"), not null
#  theme                 :string           default("light"), not null
#  first_name            :string
#  last_name             :string
#

class UserSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :email, :first_name, :last_name, :name,
             :username, :twitter, :biography, :website,
             :facebook_id, :facebook_access_token, :photo_thumb_url,
             :photo_large_url, :state, :theme

  has_many :categories
  has_many :user_categories
  has_many :organizations
  has_many :organization_memberships
  has_many :roles
  has_many :user_roles
  has_many :skills
  has_many :user_skills

  def photo_thumb_url
    object.photo.url(:thumb)
  end

  def photo_large_url
    object.photo.url(:large)
  end

  def email
    serialize_if_current_user(object.email)
  end

  def facebook_id
    serialize_if_current_user(object.facebook_id)
  end

  def facebook_access_token
    serialize_if_current_user(object.facebook_access_token)
  end

  private

    def serialize_if_current_user(attribute)
      (current_user? || @instance_options[:include_email]) ? attribute : nil
    end

    def current_user?
      object == scope
    end
end
