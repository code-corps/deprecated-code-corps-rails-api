class ContributorPolicy
  attr_reader :user, :contributor, :project

  def initialize(user, contributor)
    @user = user

    if contributor.is_a? Contributor
      @contributor = contributor
      @project = contributor.project
    end
  end

  def index?
    return true
  end

  def create?
    return unless contributor_for_user.present?

    return true if @contributor.owner? && current_user_is_owner_of_project?
    return true if current_user_is_at_least_admin_on_project? && !contributor.owner?
    return true if @contributor.pending?
  end

  def update?
    if current_user_is_at_least_admin_on_project?
      # Approve pending contributor to become a collaborator
      return true if contributor.status_was == "pending" and contributor.collaborator?
    end

    if current_user_is_owner_of_project?
      # Promote a collaborator to admin
      return true if contributor.status_was == "collaborator" and contributor.admin?
      # Demote an admin to collaborator
      return true if contributor.status_was == "admin" and contributor.collaborator?
    end

    return false
  end

  def delete?
    if current_user_is_at_least_admin_on_project?
      return true if contributor.pending? or contributor.collaborator?
    end

    if current_user_is_owner_of_project?
      return true if contributor.admin?
    end

    return false
  end

  private
    def contributor_for_user
      @contributor_for_user ||= Contributor.find_by(user: user, project: project)
    end

    def current_user_is_at_least_admin_on_project?
      current_user_is_admin_on_project? or current_user_is_owner_of_project?
    end

    def current_user_is_admin_on_project?
      contributor_for_user.present? and contributor_for_user.admin?
    end

    def current_user_is_owner_of_project?
      contributor_for_user.present? and contributor_for_user.owner?
    end
end
