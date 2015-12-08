class ProjectPolicy
  def initialize (user, project)
    @user = user
    @project = project
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def update?
    true
  end
end
