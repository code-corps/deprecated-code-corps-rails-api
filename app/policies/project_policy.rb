class ProjectPolicy
  attr_reader :user, :project

  def initialize(user, project)
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
    return unless @user.present?
    return true if @user.admin?
    return true if @user == @project.owner
  end

  def update?
    return unless @user.present?
    return true if @user == @project.owner
  end
end
