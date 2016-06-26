require "rails_helper"

describe RoleSkillPolicy do
  subject { described_class }

  let(:regular_user) { build_stubbed(:user) }
  let(:role_skill) { build_stubbed(:role_skill) }
  let(:site_admin) { build_stubbed(:user, admin: true) }

  permissions :index?, :show? do
    context "as a logged out user" do
      it "can view all" do
        expect(subject).to permit(nil, role_skill)
      end
    end

    context "as a regular user" do
      it "can view all" do
        expect(subject).to permit(regular_user, role_skill)
      end
    end

    context "as a site admin" do
      it "can view all" do
        expect(subject).to permit(site_admin, role_skill)
      end
    end
  end

  permissions :create?, :destroy? do
    context "as a logged out user" do
      it "is not permitted" do
        expect(subject).to_not permit(nil, role_skill)
      end
    end

    context "as a regular user" do
      it "is not permitted" do
        expect(subject).to_not permit(regular_user, role_skill)
      end
    end

    context "as a site admin" do
      it "is permitted" do
        expect(subject).to permit(site_admin, role_skill)
      end
    end
  end
end
