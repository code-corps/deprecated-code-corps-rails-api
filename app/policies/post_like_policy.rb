class PostLikePolicy
  attr_reader :user, :post_like

  def initialize(user, post_like)
    @user = user
    @post_like = post_like
  end

  def create?
    user.present?
  end

  def destroy?
    post_like.user_id == user.id
  end
end
