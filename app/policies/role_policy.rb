class RolePolicy
  def initialize(user, role)
    @user = user
    @role = role
  end

  def index?
    true
  end

  def create?
    return unless @user.present?
    @user.admin?
  end

  def update?
    return unless @user.present?
    @user.admin?
  end
end
