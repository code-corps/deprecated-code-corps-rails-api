class PostImagePolicy
  attr_reader :user, :post_image

  def initialize(user, post_image)
    @user = user
    @post_image = post_image
  end

  def create?
    return false unless user.present?
    return false unless post.user_id == user.id
    return true
  end

  private
    def post
      @post ||= post_image.post
    end
end
