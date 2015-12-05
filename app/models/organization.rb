class Organization < ActiveRecord::Base
  has_many :organization_memberships
  has_many :members, through: :organization_memberships
  has_many :teams
  has_many :projects, as: :owner

  before_validation :add_slug_if_blank

  validates_presence_of :name

  validates_presence_of :slug
  validates :slug, exclusion: { in: Rails.configuration.x.reserved_routes }
  validates :slug, slug: true
  validates :slug, uniqueness: { case_sensitive: false }
  validates :slug, length: { maximum: 39 } # This is GitHub's maximum username limit

  validate :slug_is_not_duplicate

  after_save :create_or_update_member

  def admins
    admin_memberships.map(&:member)
  end

  def admin_memberships
    organization_memberships.admin
  end

  private

    def slug_is_not_duplicate
      if Member.where.not(model: self).where('lower(slug) = ?', slug.try(:downcase)).present?
        errors.add(:slug, "has already been taken by a user")
      end
    end

    def create_or_update_member
      if slug_was
        route_slug = slug_was
      else
        route_slug = slug
      end

      Member.lock.find_or_create_by!(model: self, slug: route_slug).tap do |r|
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
