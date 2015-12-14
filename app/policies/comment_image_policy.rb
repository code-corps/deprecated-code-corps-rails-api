class CommentImagePolicy
  attr_reader :user, :comment_image

  def initialize(user, comment_image)
    @user = user
    @comment_image = comment_image
  end

  def create?
    return false unless user.present?
    return false unless comment.user_id == user.id
    return true
  end

  private
    def comment
      @comment ||= comment_image.comment
    end
end
