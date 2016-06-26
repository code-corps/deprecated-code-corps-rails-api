class ImportSkillFailurePolicy
  attr_reader :user, :import_skill_failure

  def initialize(user, import_skill_failure)
    @user = user
    @import = import_skill_failure
  end

  def index?
    return true if user.admin?
  end
end
