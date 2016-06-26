require "rails_helper"

describe ImportPolicy do
  subject { described_class }

  permissions :create? do
    context "user is not admin" do
      let(:user) { create(:user) }

      it "denies permission" do
        expect(subject).not_to permit(user, Import.new)
      end
    end

    context "user is an admin" do
      let(:user) { create(:user, :admin) }

      it "allows permission" do
        expect(subject).to permit(user, Import.new)
      end
    end
  end
end
