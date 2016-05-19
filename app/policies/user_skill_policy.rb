class UserSkillPolicy
  attr_reader :user, :user_skill

  def initialize(user, user_skill)
    @user = user
    @user_skill = user_skill
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    return unless user.present?
    user_skill.user_id == user.id
  end

  def destroy?
    return unless user.present?
    user_skill.user_id == user.id
  end
end
