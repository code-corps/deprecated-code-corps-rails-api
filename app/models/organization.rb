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

  def admins
    admin_memberships.map(&:member)
  end

  def admin_memberships
    organization_memberships.admin
  end

  private

    def add_slug_if_blank
      unless self.slug.present?
        self.slug = self.name.try(:parameterize)
      end
    end
end
