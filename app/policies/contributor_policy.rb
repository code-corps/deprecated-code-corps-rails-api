class ContributorPolicy
  attr_reader :user, :contributor, :project

  def initialize(user, contributor)
    @user = user
    @contributor = contributor
  end

  def index?
    true
  end

  def create?
    @user.present?
  end

  def update?
    @project = @contributor.project

    if current_user_is_at_least_admin_on_project?
      return true if contributor.status_was == "pending" and contributor.collaborator?
    end

    if current_user_is_owner_of_project?
      return true if contributor.status_was == "collaborator" and contributor.admin?
      return true if contributor.status_was == "admin" and contributor.collaborator?
    end

    return false
  end

  private
    def contributor_for_user
      @contributor_for_user ||= Contributor.find_by(user: @user, project: @project)
    end

    def current_user_is_at_least_admin_on_project?
      current_user_is_admin_on_project? or current_user_is_owner_of_project?
    end

    def current_user_is_admin_on_project?
      contributor_for_user.admin?
    end

    def current_user_is_owner_of_project?
      contributor_for_user.owner?
    end

end
