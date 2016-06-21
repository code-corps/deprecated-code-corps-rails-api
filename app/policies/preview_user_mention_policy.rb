class PreviewUserMentionPolicy
  attr_reader :user, :preview_user_mention

  def initialize(user, preview_user_mention)
    @user = user
    @preview_user_mention = preview_user_mention
  end

  def index?
    true
  end
end
