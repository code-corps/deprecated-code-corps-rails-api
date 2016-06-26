require "rails_helper"

describe SkillPolicy do
  subject { described_class }

  let(:regular_user) { build_stubbed(:user) }
  let(:site_admin) { build_stubbed(:user, admin: true) }
  let(:skill) { build_stubbed(:skill) }

  permissions :index?, :show?, :search? do
    context "as a logged out user" do
      it "can view all skills" do
        expect(subject).to permit(nil, skill)
      end
    end

    context "as a regular user" do
      it "can view all skills" do
        expect(subject).to permit(regular_user, skill)
      end
    end

    context "as a site admin" do
      it "can view all skills" do
        expect(subject).to permit(site_admin, skill)
      end
    end
  end

  permissions :create?, :update? do
    context "as a logged out user" do
      it "is not permitted to create/update skills" do
        expect(subject).to_not permit(nil, skill)
      end
    end

    context "as a regular user" do
      it "is not permitted to create/update skills" do
        expect(subject).to_not permit(regular_user, skill)
      end
    end

    context "as a site admin" do
      it "is permitted to create/update skills" do
        expect(subject).to permit(site_admin, skill)
      end
    end
  end
end
