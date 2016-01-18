# == Schema Information
#
# Table name: projects
#
#  id                 :integer          not null, primary key
#  title              :string           not null
#  description        :string
#  owner_id           :integer
#  owner_type         :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  icon_file_name     :string
#  icon_content_type  :string
#  icon_file_size     :integer
#  icon_updated_at    :datetime
#  base64_icon_data   :text
#  contributors_count :integer
#  slug               :string           not null
#

class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :icon_thumb_url, :icon_large_url, :contributors_count

  has_many :contributors

  has_many :github_repositories

  def icon_thumb_url
    object.icon.url(:thumb)
  end

  def icon_large_url
    object.icon.url(:large)
  end
end
