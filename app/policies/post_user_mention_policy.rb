class PostUserMentionPolicy
  attr_reader :user, :post_user_mention

  def initialize(user, post_user_mention)
    @user = user
    @post_user_mention = post_user_mention
  end

  def index?
    true
  end
end
