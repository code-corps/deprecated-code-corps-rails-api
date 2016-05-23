class CategoryPolicy
  attr_reader :user, :category

  def initialize(user, category)
    @user = user
    @category = category
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    return unless user.present?
    user.admin?
  end

  def update?
    return unless user.present?
    user.admin?
  end
end
