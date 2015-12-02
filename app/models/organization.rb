class Organization < ActiveRecord::Base

  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :organization_memberships
  has_many :members, through: :organization_memberships
  has_many :teams
  has_many :projects, as: :owner

  validates_presence_of :name
  validates :name, slug: true
  validates :name, uniqueness: { case_sensitive: false }
  validates :name, length: { maximum: 39 } # This is GitHub's maximum username limit

  validates_presence_of :slug

  def admins
    admin_memberships.map(&:member)
  end

  def admin_memberships
    organization_memberships.admin
  end
end
