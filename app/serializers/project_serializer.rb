# == Schema Information
#
# Table name: projects
#
#  id                        :integer          not null, primary key
#  title                     :string           not null
#  description               :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  icon_file_name            :string
#  icon_content_type         :string
#  icon_file_size            :integer
#  icon_updated_at           :datetime
#  base64_icon_data          :text
#  slug                      :string           not null
#  organization_id           :integer          not null
#  long_description_body     :text
#  long_description_markdown :text
#  open_posts_count          :integer          default(0), not null
#  closed_posts_count        :integer          default(0), not null
#

class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :slug, :title, :description, :icon_thumb_url, :icon_large_url,
             :long_description_body, :long_description_markdown,
             :open_posts_count, :closed_posts_count

  has_many :categories
  has_many :github_repositories
  has_many :roles
  has_many :skills

  belongs_to :organization

  def icon_thumb_url
    object.icon.url(:thumb)
  end

  def icon_large_url
    object.icon.url(:large)
  end
end
