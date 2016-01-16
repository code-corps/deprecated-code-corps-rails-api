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
    return false unless organization_member_for_user

    # Can create if a contributor with permissions
    return true if current_user_is_at_least_contributor_to_organization?
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
    return true if current_user_is_at_least_contributor_to_organization?
  end

  private

    def organization_member_for_user
      @organization_member_for_user ||= OrganizationMembership.find_by(member: user, organization: post.project.owner)
    end

    def current_user_is_at_least_contributor_to_organization?
      return false unless organization_member_for_user
      return true if organization_member_for_user.contributor? or organization_member_for_user.admin? or organization_member_for_user.owner?
    end

    def current_user_is_at_least_admin_on_project?
      return false unless organization_member_for_user
      return true if organization_member_for_user.admin? or organization_member_for_user.owner?
    end
end
