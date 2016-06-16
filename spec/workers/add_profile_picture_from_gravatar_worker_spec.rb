require "rails_helper"

describe AddProfilePictureFromGravatarWorker do
  before do
    @user = create(:user, email: "fake_email@email.com")
    @user_gravatar = create(:user, email: "bradyrudesill@gmail.com")
  end

  context "when the user does not have a gravatar image", vcr: { cassette_name: "workers/add gravatar image worker/does not add the gravatar" } do
    it "does not add the gravatar" do
      AddProfilePictureFromGravatarWorker.new.perform(@user.id)

      @user.reload

      expect(@user.photo.to_s).to include "user_default"
    end
  end

  context "when the user has a gravatar image", vcr: { cassette_name: "workers/add gravatar image worker/adds the gravatar" } do
    it "adds the gravatar" do
      expect_any_instance_of(Analytics).to receive(:track_added_profile_picture_from_gravatar)
      AddProfilePictureFromGravatarWorker.new.perform(@user_gravatar.id)

      @user_gravatar.reload

      expect(@user_gravatar.photo.to_s).to_not include "user_default"
    end
  end
end
