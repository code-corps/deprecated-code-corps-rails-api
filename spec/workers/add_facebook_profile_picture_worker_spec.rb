require 'rails_helper'

describe AddFacebookProfilePictureWorker do

  before do
    oauth = Koala::Facebook::OAuth.new(ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_APP_SECRET"], ENV["FACEBOOK_REDIRECT_URL"])
    test_users = Koala::Facebook::TestUsers.new(app_id: ENV["FACEBOOK_APP_ID"], secret: ENV["FACEBOOK_APP_SECRET"])
    facebook_user = test_users.create(true, "email,user_friends")
    @user = create(:user, facebook_id: facebook_user["id"], facebook_access_token: facebook_user["access_token"])
  end

  it 'adds a profile picture from facebook', vcr: { cassette_name: 'workers/add facebook profile picture worker/adds a profile picture from facebook' } do
    AddFacebookProfilePictureWorker.new.perform(@user.id)
    @user.reload
    expect(@user.photo.path).to_not be_nil
  end
end