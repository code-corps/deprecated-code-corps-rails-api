# == Schema Information
#
# Table name: organization_memberships
#
#  id              :integer          not null, primary key
#  role            :string           default("pending"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  member_id       :integer
#  organization_id :integer
#

class OrganizationMembership < ApplicationRecord
  belongs_to :organization
  belongs_to :member, class_name: "User"

  validates_uniqueness_of :member_id, scope: :organization_id

  after_create :track_created
  after_save :track_changed
  after_destroy :track_destroyed

  enum role: {
    pending: "pending",
    contributor: "contributor",
    admin: "admin",
    owner: "owner"
  }

  private

    def role_was_pending?
      role_was == "pending"
    end

    def track_changed
      if role_was_pending? && !pending?
        analytics.track_approved_organization_membership(self)
      end
    end

    def track_created
      if pending?
        analytics.track_requested_organization_membership(self)
      elsif contributor?
        analytics.track_created_organization_membership(self)
      elsif admin?
        analytics.track_created_organization_membership(self)
      elsif owner?
        analytics.track_created_organization_membership(self)
      end
    end

    def track_destroyed
      if role_was_pending?
        analytics.track_rejected_organization_membership(self)
      else
        analytics.track_removed_organization_membership(self)
      end
    end

    def analytics
      @analytics ||= Analytics.new(member)
    end
end
