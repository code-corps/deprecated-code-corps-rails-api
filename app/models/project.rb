# == Schema Information
#
# Table name: projects
#
#  id                :integer          not null, primary key
#  title             :string           not null
#  description       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  icon_file_name    :string
#  icon_content_type :string
#  icon_file_size    :integer
#  icon_updated_at   :datetime
#  base64_icon_data  :text
#  slug              :string           not null
#  organization_id   :integer          not null
#

class Project < ActiveRecord::Base
  ASSET_HOST_FOR_DEFAULT_ICON = "https://d3pgew4wbk2vb1.cloudfront.net/icons".freeze

  belongs_to :organization

  has_many :project_categories
  has_many :categories, through: :project_categories
  has_many :project_skills
  has_many :skills, through: :project_skills
  has_many :github_repositories
  has_many :posts

  has_attached_file :icon,
                    styles: {
                      large: "500x500#",
                      thumb: "100x100#"
                    },
                    path: "projects/:id/:style.:extension",
                    default_url: ASSET_HOST_FOR_DEFAULT_ICON + "/project_default_:style.png"

  before_validation :add_slug_if_blank

  validates :title, presence: true
  validates :slug, slug: true
  validate :slug_is_not_duplicate

  validates_presence_of :organization

  validates_attachment_content_type :icon,
                                    content_type: %r{^image\/(png|gif|jpeg)}

  validates_attachment_size :icon, less_than: 10.megabytes

  private

    def slug_is_not_duplicate
      if Project.where.not(id: self.id).where(organization: self.organization).where('lower(slug) = ?', slug.try(:downcase)).present?
        errors.add(:slug, "has already been taken")
      end
    end

    def add_slug_if_blank
      unless self.slug.present?
        self.slug = self.title.try(:parameterize)
      end
    end
end
