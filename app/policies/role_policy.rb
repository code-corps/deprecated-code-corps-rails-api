class RolePolicy
  def initialize (user, role)
    @user = user
    @role = role
  end

  def index?
    true
  end
end
