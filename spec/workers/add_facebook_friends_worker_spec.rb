require 'rails_helper'

describe AddFacebookFriendsWorker do

  before do
    oauth = Koala::Facebook::OAuth.new(ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_APP_SECRET"], ENV["FACEBOOK_REDIRECT_URL"])
    test_users = Koala::Facebook::TestUsers.new(app_id: ENV["FACEBOOK_APP_ID"], secret: ENV["FACEBOOK_APP_SECRET"])
    @facebook_user = test_users.create(true, "email,user_friends")
    @friend = test_users.create(true, "email,user_friends")
    test_users.befriend(@facebook_user, @friend)
    @original_user = create(:user, facebook_id: @facebook_user["id"], facebook_access_token: @facebook_user["access_token"])
    @friend_user = create(:user, facebook_id: @friend["id"])
  end

  it "adds friends from facebook", vcr: { cassette_name: 'workers/add facebook friends/adds friends from facebook' } do
    AddFacebookFriendsWorker.new.perform(@original_user.id)

    expect(@original_user.following?(@friend_user)).to eq true
    expect(@friend_user.following?(@original_user)).to eq true
  end
end
