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
    # unauthenticated user cannot create
    return false unless user.present?

    # user cannot create posts for other users
    return false unless post.user == user

    # non-contributors can create issues or ideas
    return true if post.issue?
    return true if post.idea?

    # contributors can create all types of posts
    return true if current_user_is_at_least_contributor_to_organization?
  end

  def update?
    # unauthenticated user cannot update
    return false unless user.present?

    # admin can update any post, even that belonging to other users
    return true if current_user_is_at_least_admin_in_organization?

    # user can update their own post
    return true if post.user == user
  end

  private

    def user_is_member_of_organization
      organization_member_for_user.present?
    end

    def organization_member_for_user
      @organization_member_for_user ||= OrganizationMembership.find_by(
        member_id: user.id, organization_id: post.project.organization_id)
    end

    def current_user_is_at_least_contributor_to_organization?
      return false unless organization_member_for_user
      return true if organization_member_for_user.contributor? ||
                     organization_member_for_user.admin? ||
                     organization_member_for_user.owner?
    end

    def current_user_is_at_least_admin_in_organization?
      return false unless organization_member_for_user
      return true if organization_member_for_user.admin? || organization_member_for_user.owner?
    end
end
