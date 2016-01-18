require 'rails_helper'

describe GithubRepositoryPolicy do

  subject { described_class }

  before do
    @project = create(:project)

    @author = create(:user)
    @other_user = create(:user)

    @comment = create(:comment, user: @author)
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
      expect(subject).to permit(@other_user, Comment)
    end
  end

  permissions :update? do
    it "is not permitted for unauthenticated users" do
      expect(subject).not_to permit(nil, Comment)
    end

    it "is not permitted for authenticated users who did not create the comment" do
      expect(subject).not_to permit(@other_user, @comment)
    end

    it "is permitted for authenticated users who did create the comment" do
      expect(subject).to permit(@author, @comment)
    end
  end
end
