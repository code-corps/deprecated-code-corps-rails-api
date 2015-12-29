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
    # Cannot create there's no user
    return unless @user.present?

    # Can create issue posts for any user
    return true if post.issue?

    # Cannot create if not a contributor
    return false unless contributor_for_user

    # Can create if a contributor with permissions
    return true if current_user_is_at_least_collaborator_on_project?
  end

  def update?
    # Can update if the user who posted
    return true if @user == post.user

    # Cannot update if not a contributor
    return false unless contributor_for_user

    # Can update if the user is a project admin
    return true if current_user_is_at_least_admin_on_project?
  end

  private

    def contributor_for_user
      @contributor_for_user ||= Contributor.find_by(user: user, project: post.project)
    end

    def current_user_is_at_least_collaborator_on_project?
      return true if contributor_for_user.collaborator? or contributor_for_user.admin? or contributor_for_user.owner?
    end

    def current_user_is_at_least_admin_on_project?
      return true if contributor_for_user.admin? or contributor_for_user.owner?
    end
end
