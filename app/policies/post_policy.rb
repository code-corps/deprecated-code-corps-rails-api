class PostPolicy
  attr_reader :user, :post

  def initialize(user, post)
    @user = user
    @post = post
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    # Cannot create if there's no user
    return unless user.present?

    # Cannot create if not the user who's posting
    return false unless post.user == user

    # Can create issue posts for any user
    return true if post.issue?

    # Cannot create if not a contributor
    return false unless contributor_for_user

    # Can create if a contributor with permissions
    return true if current_user_is_at_least_collaborator_on_project?
  end

  def update?
    # Cannot update if there's no user
    return unless user.present?

    # Can update if the user is a project admin
    return true if current_user_is_at_least_admin_on_project?

    # Cannot update if not the user who posted
    return false unless post.user == user

    # Can create issue posts for any user
    return true if post.issue?

    # Can create if a contributor with permissions
    return true if current_user_is_at_least_collaborator_on_project?
  end

  private

    def contributor_for_user
      @contributor_for_user ||= Contributor.find_by(user: user, project: post.project)
    end

    def current_user_is_at_least_collaborator_on_project?
      return false unless contributor_for_user
      return true if contributor_for_user.collaborator? or contributor_for_user.admin? or contributor_for_user.owner?
    end

    def current_user_is_at_least_admin_on_project?
      return false unless contributor_for_user
      return true if contributor_for_user.admin? or contributor_for_user.owner?
    end
end
