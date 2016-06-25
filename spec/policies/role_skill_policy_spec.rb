require "rails_helper"

describe RoleSkillPolicy do
  subject { described_class }

  before do
    @role_skill = create(:role_skill)
    @regular_user = create(:user)
    @site_admin = create(:user, admin: true)
  end

  permissions :index?, :show? do
    context "as a logged out user" do
      it "can view all" do
        expect(subject).to permit(nil, @role)
      end
    end

    context "as a regular user" do
      it "can view all" do
        expect(subject).to permit(@regular_user, @role)
      end
    end

    context "as a site admin" do
      it "can view all" do
        expect(subject).to permit(@site_admin, @role)
      end
    end
  end

  permissions :create?, :destroy? do
    context "as a logged out user" do
      it "is not permitted" do
        expect(subject).to_not permit(nil, @role)
      end
    end

    context "as a regular user" do
      it "is not permitted" do
        expect(subject).to_not permit(@regular_user, @role)
      end
    end

    context "as a site admin" do
      it "is permitted" do
        expect(subject).to permit(@site_admin, @role)
      end
    end
  end
end
