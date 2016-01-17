class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :icon_thumb_url, :icon_large_url

  has_many :github_repositories

  belongs_to :organization

  def icon_thumb_url
    object.icon.url(:thumb)
  end

  def icon_large_url
    object.icon.url(:large)
  end
end
