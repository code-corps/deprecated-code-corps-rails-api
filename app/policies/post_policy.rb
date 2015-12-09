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
    return unless @user.present?
    return true if post.issue?
    return false unless contributor_for_user
    return true if current_user_is_at_least_collaborator_on_project?
  end

  def update?
    return true if @user == post.user
    return false unless contributor_for_user
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
end
