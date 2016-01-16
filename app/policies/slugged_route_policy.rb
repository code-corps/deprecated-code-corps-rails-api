class SluggedRoutePolicy
  def initialize (user, member)
    @user = user
    @member = member
  end

  def show?
    true
  end
end
