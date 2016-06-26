class CommentImagePolicy
  attr_reader :user, :comment_image

  def initialize(user, comment_image)
    @user = user
    @comment_image = comment_image
  end

  def create?
    # Cannot create if there's no user
    return false unless user.present?

    # Cannot create if they're not the same user
    return false unless comment.user_id == user.id

    # Can create comments for any user
    true
  end

  private

    def comment
      @comment ||= comment_image.comment
    end
end
