class UserCategoryPolicy
  attr_reader :user, :user_category

  def initialize(user, user_category)
    @user = user
    @user_category = user_category
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    return unless user.present?
    user_category.user_id == user.id
  end

  def destroy?
    return unless user.present?
    user_category.user_id == user.id
  end
end
