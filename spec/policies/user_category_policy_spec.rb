require "rails_helper"

describe UserCategoryPolicy do
  subject { described_class }

  let(:another_user) { build_stubbed(:user) }
  let(:user) { build_stubbed(:user) }
  let(:user_category) { build_stubbed(:user_category, user: user) }

  permissions :index?, :show? do
    context "as a logged out user" do
      it "can view all" do
        expect(subject).to permit(nil, user_category)
      end
    end

    context "as the user" do
      it "can view all" do
        expect(subject).to permit(user, user_category)
      end
    end

    context "as another user" do
      it "can view all" do
        expect(subject).to permit(another_user, user_category)
      end
    end
  end

  permissions :create?, :destroy? do
    context "as a logged out user" do
      it "is not permitted" do
        expect(subject).to_not permit(nil, user_category)
      end
    end

    context "as a regular user" do
      it "is permitted" do
        expect(subject).to permit(user, user_category)
      end
    end

    context "as a site admin" do
      it "is not permitted" do
        expect(subject).to_not permit(another_user, user_category)
      end
    end
  end
end
