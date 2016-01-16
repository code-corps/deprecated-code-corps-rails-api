class SluggedRoutePolicy
  def initialize (user, slugged_route)
    @user = user
    @slugged_route = slugged_route
  end

  def show?
    true
  end
end
