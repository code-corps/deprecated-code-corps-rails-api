class GithubRepositoryPolicy
  attr_reader :user, :github_repository

  def initialize(user, github_repository)
    @user = user
    @github_repository = github_repository
  end

  def create?
    return false unless @user.present?
    return false unless @github_repository.present?

    project = @github_repository.project

    return false unless project.present?

    return user_allowed_to_add_repos_to_project? @user, project
  end

  def user_allowed_to_add_repos_to_project? user, project
    # TODO: user has a role in the organization or an organization team, which would
    # also allow him to add repos to project
    # TODO: user has a collaborator status on project which would allow him to add repos
    project.owner_id == user.id
  end
end
