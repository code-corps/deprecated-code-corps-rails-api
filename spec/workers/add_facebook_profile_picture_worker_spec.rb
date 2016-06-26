require "rails_helper"

describe AddFacebookProfilePictureWorker, local_skip: true do
  before do
    test_users = Koala::Facebook::TestUsers.new(app_id: ENV["FACEBOOK_APP_ID"], secret: ENV["FACEBOOK_APP_SECRET"])
    facebook_user = test_users.create(true, "email,user_friends")
    @user = create(:user, facebook_id: facebook_user["id"], facebook_access_token: facebook_user["access_token"])
  end

  it "adds a profile picture from facebook", vcr: { cassette_name: "workers/add facebook profile picture worker/adds a profile picture from facebook" } do
    expect_any_instance_of(Analytics).to receive(:track_added_profile_picture_from_facebook)
    AddFacebookProfilePictureWorker.new.perform(@user.id)
    @user.reload
    expect(@user.photo.path).to_not be_nil
  end
end
