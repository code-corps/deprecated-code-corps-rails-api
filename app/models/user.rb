class User < ActiveRecord::Base
  include Clearance::User
  extend FriendlyId

  friendly_id :username, use: :slugged

  has_many :organization_memberships, foreign_key: "member_id"
  has_many :organizations, through: :organization_memberships
  has_many :team_memberships, foreign_key: "member_id"
  has_many :teams, through: :team_memberships
  has_many :projects, as: :owner
  has_many :posts
  has_many :comments
  has_many :user_skills
  has_many :skills, through: :user_skills

  validates :username, presence: { message: "can't be blank" }
  validates :username, slug: true
  validates :username, uniqueness: { case_sensitive: false }
  validates :username, length: { maximum: 39 } # This is GitHub's maximum username limit

  validates :website, format: { with: /\A((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,}(([0-9]{1,5})?\/.*)?#=\z/ix }, allow_blank: true

  validates_presence_of :slug
end
