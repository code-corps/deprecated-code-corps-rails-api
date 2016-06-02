# == Schema Information
#
# Table name: users
#
#  id                    :integer          not null, primary key
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  email                 :string           not null
#  encrypted_password    :string(128)      not null
#  confirmation_token    :string(128)
#  remember_token        :string(128)      not null
#  username              :string
#  admin                 :boolean          default(FALSE), not null
#  website               :text
#  twitter               :string
#  biography             :text
#  facebook_id           :string
#  facebook_access_token :string
#  base64_photo_data     :string
#  photo_file_name       :string
#  photo_content_type    :string
#  photo_file_size       :integer
#  photo_updated_at      :datetime
#  name                  :text
#

class User < ActiveRecord::Base
  ASSET_HOST_FOR_DEFAULT_PHOTO = "https://d3pgew4wbk2vb1.cloudfront.net/icons".freeze

  include AASM
  include Clearance::User

  has_many :organization_memberships, foreign_key: "member_id"
  has_many :organizations, through: :organization_memberships
  has_many :posts
  has_many :comments
  has_many :user_skills
  has_many :skills, through: :user_skills
  has_many :user_roles
  has_many :roles, through: :user_roles
  has_many :user_categories
  has_many :categories, through: :user_categories

  has_many :active_relationships, class_name: "UserRelationship", foreign_key: "follower_id", dependent: :destroy
  has_many :passive_relationships, class_name: "UserRelationship", foreign_key: "following_id", dependent: :destroy
  has_many :following, through: :active_relationships, source: :following
  has_many :followers, through: :passive_relationships, source: :follower

  has_one :slugged_route, as: :owner

  has_attached_file :photo,
                    styles: {
                      large: "500x500#",
                      thumb: "100x100#"
                    },
                    path: "users/:id/:style.:extension",
                    default_url: ASSET_HOST_FOR_DEFAULT_PHOTO + "/user_default_:style.png"

  validates_attachment_content_type :photo,
                                    content_type: %r{^image\/(png|gif|jpeg)}

  validates_attachment_size :photo, less_than: 10.megabytes

  validates :username, presence: { message: "can't be blank" }, obscenity: {message: "may not be obscene"}
  validates :username, exclusion: { in: Rails.configuration.x.reserved_routes }
  validates :username, slug: true
  validates :username, uniqueness: { case_sensitive: false }
  validates :username, length: { maximum: 39 } # This is GitHub's maximum username limit

  validates :website, format: { with: /\A((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,}(([0-9]{1,5})?\/.*)?#=\z/ix }, allow_blank: true

  validate :slug_is_not_duplicate
  validate :can_transition

  before_save :attempt_transition
  after_save :create_or_update_slugged_route

  attr_accessor :state_transition

  # User onboarding
  aasm do
    state :signed_up, initial: true
    state :selected_categories
    state :selected_roles
    state :selected_skills

    event :select_categories do
      transitions from: :signed_up, to: :selected_categories
    end

    event :select_roles do
      transitions from: :selected_categories, to: :selected_roles
    end

    event :select_skills do
      transitions from: :selected_roles, to: :selected_skills
    end
  end

  def state
    aasm_state
  end

  # Follows a user.
  def follow(other_user)
    active_relationships.create(following_id: other_user.id)
  end

  # Unfollows a user.
  def unfollow(other_user)
    active_relationships.find_by(following_id: other_user.id).destroy
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

  private

    def can_transition
      return if state_transition.blank?
      errors.add(:state, "cannot transition") unless send("may_#{state_transition}?")
    end

    def attempt_transition
      send(state_transition) if state_transition.present?
    end

    def slug_is_not_duplicate
      if SluggedRoute.where.not(owner: self).where("lower(slug) = ?", username.try(:downcase)).present?
        errors.add(:username, "has already been taken by an organization")
      end
    end

    def create_or_update_slugged_route
      if username_was
        slug = username_was
      else
        slug = username
      end

      SluggedRoute.lock.find_or_create_by!(owner: self, slug: slug).tap do |r|
        r.slug = username
        r.save!
      end
    end
end
