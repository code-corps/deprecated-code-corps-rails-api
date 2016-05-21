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
  include AASM

  ASSET_HOST_FOR_DEFAULT_ICON = "https://d3pgew4wbk2vb1.cloudfront.net/icons".freeze

  belongs_to :organization

  has_many :project_categories
  has_many :categories, through: :project_categories
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
  before_save :publish_changes

  validates :title, presence: true
  validates :slug, slug: true
  validate :slug_is_not_duplicate

  validates :description, presence: true, if: :publishing_or_published?
  validates :categories, presence: true, if: :publishing_or_published?

  validates_presence_of :organization

  validates_attachment_content_type :icon,
                                    content_type: %r{^image\/(png|gif|jpeg)}

  validates_attachment_size :icon, less_than: 10.megabytes

  attr_accessor :publishing
  alias_method :publishing?, :publishing

  aasm do
    state :created, initial: true
    state :published

    event :publish do
      transitions from: :created, to: :published, guard: :can_publish?
    end
  end

  def update(publishing)
    @publishing = publishing
    save
  end

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

    def can_publish?
      title.present? &&
        description.present? &&
        categories.present?
    end

    def publish_changes
      return unless valid?
      return unless publishing?

      publish if created?
    end

    def publishing_or_published?
      publishing? || published?
    end
end
