require "rails_helper"

describe UserPolicy do
  subject { described_class }

  let(:admin_user) { build_stubbed(:user, admin: true) }
  let(:user) { build_stubbed(:user) }

  permissions :index? do
    it "is permitted for anyone" do
      expect(subject).to permit(nil, User)
    end
  end

  permissions :show? do
    it "is permitted for anyone" do
      expect(subject).to permit(nil, User)
    end
  end

  permissions :create? do
    it "is permitted for anyone" do
      expect(subject).to permit(nil, User)
    end
  end

  permissions :update? do
    it "is permitted when user is the current user" do
      expect(subject).to permit(user, user)
    end

    it "is not permitted when user is not the current user" do
      expect(subject).to_not permit(user, build_stubbed(:user))
    end

    it "is permitted for admin users" do
      expect(subject).to permit(admin_user, User)
    end
  end

  permissions :forgot_password? do
    it "is permitted for anyone" do
      expect(subject).to permit(nil, User)
    end
  end

  permissions :reset_password? do
    it "is permitted for anyone" do
      expect(subject).to permit(nil, User)
    end
  end
end
