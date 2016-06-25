require "rails_helper"

describe CommentPolicy do
  subject { described_class }
  let(:project) { create(:project) }
  let(:author) { create(:user) }
  let(:other_user) { create(:user) }
  let(:comment) { create(:comment, user: author) }

  permissions :post_index? do
    it "is permited for anyone" do
      expect(subject).to permit(nil, Comment)
    end
  end

  permissions :index? do
    it "is permited for anyone" do
      expect(subject).to permit(nil, Comment)
    end
  end

  permissions :show? do
    it "is permited for anyone" do
      expect(subject).to permit(nil, Comment)
    end
  end

  permissions :create? do
    it "is not permitted for unauthenticated users" do
      expect(subject).not_to permit(nil, Comment)
    end

    it "is permitted for authenticated users" do
      expect(subject).to permit(other_user, Comment)
    end
  end

  permissions :update? do
    it "is not permitted for unauthenticated users" do
      expect(subject).not_to permit(nil, Comment)
    end

    it "is not permitted for authenticated users who did not create the comment" do
      expect(subject).not_to permit(other_user, comment)
    end

    it "is permitted for authenticated users who did create the comment" do
      expect(subject).to permit(author, comment)
    end
  end
end
