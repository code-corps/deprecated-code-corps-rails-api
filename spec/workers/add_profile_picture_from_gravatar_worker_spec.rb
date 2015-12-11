require 'rails_helper'

describe AddProfilePictureFromGravatarWorker do
  before do
    @user = create(:user, email: "fake_email@email.com")
    @user_gravatar = create(:user, email: "bradyrudesill@gmail.com")
  end

  context "when the user does not have a gravatar", vcr: { cassette_name: 'workers/add gravatar image worker/adds gravatar' } do
    it "a photo has not been added" do
      AddProfilePictureFromGravatarWorker.new.perform(@user.id)

      @user.reload

      expect(@user.photo.to_s).to eq "/photos/original/missing.png"
    end
  end

  context "when the user has a gravatar", vcr: { cassette_name: 'workers/add gravatar image worker/does not add gravatar' } do
    it "a photo has been added" do
      AddProfilePictureFromGravatarWorker.new.perform(@user_gravatar.id)

      @user_gravatar.reload

      expect(@user_gravatar.photo.to_s).to_not eq "/photos/original/missing.png"
    end
  end
end