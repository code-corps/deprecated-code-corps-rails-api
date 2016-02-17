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

class Organization < ActiveRecord::Base
  has_many :organization_memberships
  has_many :members, through: :organization_memberships
  has_many :projects

  has_one :slugged_route, as: :owner

  has_attached_file :icon,
                    styles: {
                      large: "500x500#",
                      thumb: "100x100#"
                    },
                    path: "orgnizations/:id/:style.:extension"

  before_validation :add_slug_if_blank

  validates_presence_of :name

  validates :slug, presence: true
  validates :slug, obscenity: {message: "may not be obscene"}
  validates :slug, exclusion: { in: Rails.configuration.x.reserved_routes }
  validates :slug, slug: true
  validates :slug, uniqueness: { case_sensitive: false }
  validates :slug, length: { maximum: 39 } # This is GitHub's maximum username limit

  validate :slug_is_not_duplicate

  validates_attachment_content_type :icon,
                                    content_type: %r{^image\/(png|gif|jpeg)}

  validates_attachment_size :icon, less_than: 10.megabytes

  after_save :create_or_update_slugged_route

  def admins
    admin_memberships.map(&:member)
  end

  def admin_memberships
    organization_memberships.admin
  end

  def self.for_project(project)
    self.find_by(project: project)
  end

  private

    def slug_is_not_duplicate
      if SluggedRoute.where.not(owner: self).where('lower(slug) = ?', slug.try(:downcase)).present?
        errors.add(:slug, "has already been taken by a user")
      end
    end

    def create_or_update_slugged_route
      if slug_was
        route_slug = slug_was
      else
        route_slug = slug
      end

      SluggedRoute.lock.find_or_create_by!(owner: self, slug: route_slug).tap do |r|
        r.slug = slug
        r.save!
      end
    end

    def add_slug_if_blank
      unless self.slug.present?
        self.slug = self.name.try(:parameterize)
      end
    end
end
