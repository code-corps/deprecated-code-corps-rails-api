class UserSkillPolicy
  attr_reader :user, :user_skill

  def initialize(user, user_skill)
    @user = user
    @user_skill = user_skill
  end

  def create?
    user.present?
  end

  def destroy?
    user.admin? || user_skill.user_id == user.id
  end
end
