class ImportPolicy
  attr_reader :user, :import

  def initialize(user, import)
    @user = user
    @import = import
  end

  def create?
    # Cannot create if there's no user
    return false unless user.present?

    # Cannot create if they're not an admin.
    return false unless user.admin?

    # Can create import.
    true
  end
end
