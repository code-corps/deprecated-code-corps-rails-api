class User < ActiveRecord::Base
  include Clearance::User

  has_many :organization_memberships, foreign_key: "member_id"
  has_many :organizations, through: :organization_memberships
  has_many :team_memberships, foreign_key: "member_id"
  has_many :teams, through: :team_memberships
  has_many :projects, as: :owner
  has_many :posts
  has_many :comments
  has_many :user_skills
  has_many :skills, through: :user_skills

  has_one :member, as: :model

  validates :username, presence: { message: "can't be blank" }, obscenity: {message: "may not be obscene"}
  validates :username, exclusion: { in: Rails.configuration.x.reserved_routes }
  validates :username, slug: true
  validates :username, uniqueness: { case_sensitive: false }
  validates :username, length: { maximum: 39 } # This is GitHub's maximum username limit

  validates :website, format: { with: /\A((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,}(([0-9]{1,5})?\/.*)?#=\z/ix }, allow_blank: true

  validate :slug_is_not_duplicate

  after_save :create_or_update_member

  private

    def slug_is_not_duplicate
      if Member.where.not(model: self).where('lower(slug) = ?', username.try(:downcase)).present?
        errors.add(:username, "has already been taken by an organization")
      end
    end

    def create_or_update_member
      if username_was
        slug = username_was
      else
        slug = username
      end

      Member.lock.find_or_create_by!(model: self, slug: slug).tap do |r|
        r.slug = username
        r.save!
      end
    end
end
