class SkillCategoryPolicy
  def initialize (user, skill_category)
    @user = user
    @skill_category = skill_category
  end

  def index?
    true
  end
end
