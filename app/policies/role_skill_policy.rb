class RoleSkillPolicy
  attr_reader :user, :role_skill

  def initialize(user, role_skill)
    @user = user
    @role_skill = role_skill
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    return unless user.present?
    user.admin?
  end

  def destroy?
    return unless user.present?
    user.admin?
  end
end
