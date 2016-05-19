class ProjectCategoryPolicy
  attr_reader :user, :project_category

  def initialize(user, project_category)
    @user = user
    @project_category = project_category
  end

  def create?
    return unless @user.present?
    return true if @user.admin?
    return true if current_user_is_at_least_admin_in_organization?
  end

  def delete?
    return unless @user.present?
    return true if @user.admin?
    return true if current_user_is_at_least_admin_in_organization?
  end

  private

    def organization_member_for_user
      @organization_member_for_user ||= OrganizationMembership.find_by(member: user, organization: project_category.project.organization)
    end

    def current_user_is_at_least_contributor_to_organization?
      return false unless organization_member_for_user
      return true if organization_member_for_user.contributor? or organization_member_for_user.admin? or organization_member_for_user.owner?
    end

    def current_user_is_at_least_admin_in_organization?
      return false unless organization_member_for_user
      return true if organization_member_for_user.admin? or organization_member_for_user.owner?
    end
end
