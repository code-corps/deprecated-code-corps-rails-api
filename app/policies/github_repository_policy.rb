class GithubRepositoryPolicy
  attr_reader :user, :github_repository

  def initialize(user, github_repository)
    @user = user
    @github_repository = github_repository
  end

  def create?
    return false unless @user.present?
    return true if current_user_is_at_least_admin_in_organization?
  end

  private

    def project
      @project ||= github_repository.project
    end

    def organization
      @organization ||= project.organization
    end

    def organization_member_for_user
      @organization_member_for_user ||= OrganizationMembership.find_by(member: user, organization: organization)
    end

    def current_user_is_at_least_admin_in_organization?
      return false unless organization_member_for_user
      return true if organization_member_for_user.admin? or organization_member_for_user.owner?
    end
end
