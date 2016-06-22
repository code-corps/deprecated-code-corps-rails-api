class SkillPolicy
  attr_reader :user, :skill

  def initialize(user, skill)
    @user = user
    @skill = skill
  end

  def index?
    true
  end

  def create?
    return unless user.present?
    user.admin?
  end

  def update?
    return unless user.present?
    user.admin?
  end

  def search?
    true
  end
end
