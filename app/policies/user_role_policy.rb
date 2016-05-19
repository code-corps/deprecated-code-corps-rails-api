class UserRolePolicy
  attr_reader :user, :user_role

  def initialize(user, user_role)
    @user = user
    @user_role = user_role
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    return unless user.present?
    user_role.user_id == user.id
  end

  def destroy?
    return unless user.present?
    user_role.user_id == user.id
  end
end
