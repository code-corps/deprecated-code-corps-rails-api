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
#  aasm_state                :string
#  long_description_body     :text
#  long_description_markdown :text
#  open_posts_count          :integer          default(0), not null
#  closed_posts_count        :integer          default(0), not null
#

class Project < ApplicationRecord
  ASSET_HOST_FOR_DEFAULT_ICON = "https://d3pgew4wbk2vb1.cloudfront.net/icons".freeze

  belongs_to :organization

  has_many :project_categories
  has_many :categories, through: :project_categories
  has_many :project_roles
  has_many :roles, through: :project_roles
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
  before_validation :render_markdown_to_body

  validates :title, presence: true
  validates :slug, slug: true
  validate :slug_is_not_duplicate

  validates_presence_of :organization

  validates_attachment_content_type :icon,
                                    content_type: %r{^image\/(png|gif|jpeg)}

  validates_attachment_size :icon, less_than: 10.megabytes

  private

    def add_slug_if_blank
      unless self.slug.present?
        self.slug = self.title.try(:parameterize)
      end
    end

    def pipeline
      @pipeline ||= HTML::Pipeline.new [
        HTML::Pipeline::MarkdownFilter,
        HTML::Pipeline::RougeFilter
      ], gfm: true # Github-flavored markdown
    end

    def render_markdown_to_body
      return if long_description_markdown.blank?
      html = pipeline.call(long_description_markdown)
      self.long_description_body = html[:output].to_s
    end

    def slug_is_not_duplicate
      if Project.where.not(id: self.id).where(organization: self.organization).where('lower(slug) = ?', slug.try(:downcase)).present?
        errors.add(:slug, "has already been taken")
      end
    end
end
