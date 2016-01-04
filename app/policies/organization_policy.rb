class OrganizationPolicy
  attr_reader :organization, :user

  def initialize(user, organization)
    @user = user
    @organization = organization
  end

  def show?
    true
  end

  def create?
    user.admin?
  end
end
