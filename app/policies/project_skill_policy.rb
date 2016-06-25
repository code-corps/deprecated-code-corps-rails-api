class ProjectSkillPolicy
  attr_reader :user, :project_skill

  def initialize(user, project_skill)
    @user = user
    @project_skill = project_skill
  end

  def create?
    return unless user.present?
    return true if user.admin?
    return true if current_user_is_at_least_admin_in_organization?
  end

  def destroy?
    return unless user.present?
    return true if user.admin?
    return true if current_user_is_at_least_admin_in_organization?
  end

  private

    def organization
      @organization ||=
        Organization.find(project_skill.project.organization_id)
    end

    def organization_member_for_user
      @organization_member_for_user ||=
        OrganizationMembership.find_by(
          member: user, organization: organization
        )
    end

    def current_user_is_at_least_contributor_to_organization?
      return false unless organization_member_for_user
      return true if organization_member_for_user.contributor? ||
                     organization_member_for_user.admin? ||
                     organization_member_for_user.owner?
    end

    def current_user_is_at_least_admin_in_organization?
      return false unless organization_member_for_user
      return true if organization_member_for_user.admin? ||
                     organization_member_for_user.owner?
    end
end
