class OrganizationPolicy
  attr_reader :organization, :user

  def initialize(user, organization)
    @user = user
    @organization = organization
  end

  def show?
    true
  end

  def create?
    return unless @user.present?
    user.admin?
  end

  def update?
    return unless @user.present?
    return true if current_user_is_at_least_admin_in_organization?
  end

  private

    def organization_member_for_user
      @organization_member_for_user ||=
        OrganizationMembership.find_by(member: user, organization: organization)
    end

    def current_user_is_at_least_admin_in_organization?
      return false unless organization_member_for_user
      return true if organization_member_for_user.admin? || organization_member_for_user.owner?
    end
end
