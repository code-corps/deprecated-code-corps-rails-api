class CommentUserMentionPolicy
  attr_reader :user, :comment_user_mention

  def initialize(user, comment_user_mention)
    @user = user
    @comment_user_mention = comment_user_mention
  end

  def index?
    true
  end
end
