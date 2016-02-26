describe PostUserMentionPolicy do
  subject { described_class }

  permissions :index? do
    it "is permited for anyone" do
      expect(subject).to permit(nil, nil)
    end
  end
end
