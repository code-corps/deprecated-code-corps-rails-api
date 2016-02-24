# == Schema Information
#
# Table name: organizations
#
#  id                :integer          not null, primary key
#  name              :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  slug              :string           not null
#  icon_file_name    :string
#  icon_content_type :string
#  icon_file_size    :integer
#  icon_updated_at   :datetime
#  base64_icon_data  :text
#

class OrganizationSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :icon_thumb_url, :icon_large_url

  has_many :projects
  has_many :members

  def icon_thumb_url
    object.icon.url(:thumb)
  end

  def icon_large_url
    object.icon.url(:large)
  end
end
