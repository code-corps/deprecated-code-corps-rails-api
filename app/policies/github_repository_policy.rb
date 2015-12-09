class GithubRepositoryPolicy
  attr_reader :user, :github_repository

  def initialize(user, github_repository)
    @user = user
    @github_repository = github_repository
  end

  def create?
    return false unless @user.present?
    return true if user_is_at_least_admin_on_project?
  end

  def user_allowed_to_add_repos_to_project? user, project
    user_is_at_least_admin_on_project?
  end

  def contributor_for_user
    @contributor_for_user ||= Contributor.find_by(user: user, project: project)
  end

  def project
    @project ||= @github_repository.project
  end

  def user_is_at_least_admin_on_project?
    contributor_for_user.present? and (contributor_for_user.admin? or contributor_for_user.owner?)
  end
end
