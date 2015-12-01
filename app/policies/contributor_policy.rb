class ContributorPolicy
  attr_reader :user, :contributor

  def initialize(user, contributor)
    @user = user
    @contributor = contributor
  end

  def index?
    true
  end
end
