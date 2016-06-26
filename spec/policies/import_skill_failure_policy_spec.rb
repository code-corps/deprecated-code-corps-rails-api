require "rails_helper"

describe ImportSkillFailurePolicy do
  subject { described_class }

  permissions :index? do
    context "user is not admin" do
      let(:user) { create(:user) }

      it "denies permission" do
        expect(subject).not_to permit(user, ImportSkillFailure)
      end
    end

    context "user is an admin" do
      let(:user) { create(:user, :admin) }

      it "allows permission" do
        expect(subject).to permit(user, ImportSkillFailure)
      end
    end
  end
end
