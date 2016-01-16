class TeamProjectPolicy
  def initialize(user, team_project)
    @user = user
    @team_project = team_project
  end

  def create?
    return unless @user.present?
    return true if current_user_is_at_least_admin_on_project?
  end

  def update? 
    return unless @user.present?
    return true if current_user_is_at_least_admin_on_project?
  end

  def show?
    true
  end

  private

  def contributor_or_member_for_user
    @contributor_or_member_for_user ||= Contributor.find_by(user: @user, project: @team_project.project_id)

    member = Member.find_by(model_id: @user.id)
    @contributor_or_member_for_user ||= OrganizationMembership.find_by(member_id: member.id)
  end

  def current_user_is_at_least_admin_on_project?
    return false if contributor_or_member_for_user == nil
    return true if contributor_or_member_for_user.admin? or contributor_or_member_for_user.owner?
  end
end
