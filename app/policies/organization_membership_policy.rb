class OrganizationMembershipPolicy
  attr_reader :organization_membership, :user

  def initialize(user, organization_membership)
    @user = user
    @organization_membership = organization_membership
  end

  def index?
    true
  end

  def create?
    # need to be logged in to do anything
    return unless user_is_logged_in?
    # can only create pending memberships
    return unless organization_membership.pending?
    # can't create a new membership of any type if already a member
    return if user_is_member?

    true
  end

  def update?
    # need to be logged in and member to do anything
    return unless user_is_logged_in? && user_is_member?
    # pending and contributors cant do any updates
    return if user_is_contributor? || user_is_pending?
    # admins cannot promote to admin or owner
    return if user_is_admin? && (organization_membership.admin? || organization_membership.owner?)
    # admins cannot demote from admin or owner
    return if user_is_admin? && (old_role_was_admin? || old_role_was_owner?)
    # no one can demote an owner
    return if old_role_was_owner?

    true
  end

  def destroy?
    # need to be logged in and member to do anything
    return unless user_is_logged_in? && user_is_member?
    # owners and admins can destroy other roles, lesser users can destroy their own
    return unless user_is_owner? || user_is_admin? || user_is_updating_own_role?
    # admins cannot delete other admins
    return if user_is_admin? && (old_role_was_admin? && !user_is_updating_own_role?)
    # cannot delete owners
    return if old_role_was_owner?

    true
  end

  private

    def user_is_logged_in?
      user.present?
    end

    def organization
      organization_membership.organization
    end

    def membership_for_user
      organization.organization_memberships.find_by(member: user)
    end

    def user_is_member?
      membership_for_user.present?
    end

    def user_is_pending?
      user_is_member? && membership_for_user.pending?
    end

    def user_is_contributor?
      user_is_member? && membership_for_user.contributor?
    end

    def user_is_admin?
      user_is_member? && membership_for_user.admin?
    end

    def user_is_owner?
      user_is_member? && membership_for_user.owner?
    end

    def old_role_was_admin?
      organization_membership.role_was == "admin"
    end

    def old_role_was_owner?
      organization_membership.role_was == "owner"
    end

    def user_is_updating_own_role?
      organization_membership == membership_for_user
    end
end
