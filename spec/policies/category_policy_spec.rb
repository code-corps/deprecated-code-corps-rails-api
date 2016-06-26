require "rails_helper"

describe CategoryPolicy do
  subject { described_class }

  before do
    @category = build_stubbed(:category)
    @regular_user = build_stubbed(:user)
    @site_admin = build_stubbed(:user, admin: true)
  end

  permissions :index?, :show? do
    context "as a logged out user" do
      it "can view all categories" do
        expect(subject).to permit(nil, @category)
      end
    end

    context "as a regular user" do
      it "can view all categories" do
        expect(subject).to permit(@regular_user, @category)
      end
    end

    context "as a site admin" do
      it "can view all categories" do
        expect(subject).to permit(@site_admin, @category)
      end
    end
  end

  permissions :create?, :update? do
    context "as a logged out user" do
      it "is not permitted to create/update categories" do
        expect(subject).to_not permit(nil, @category)
      end
    end

    context "as a regular user" do
      it "is not permitted to create/update categories" do
        expect(subject).to_not permit(@regular_user, @category)
      end
    end

    context "as a site admin" do
      it "is permitted to create/update categories" do
        expect(subject).to permit(@site_admin, @category)
      end
    end
  end
end
