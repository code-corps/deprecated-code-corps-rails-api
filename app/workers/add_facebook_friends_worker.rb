class AddFacebookFriendsWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)

    facebook_access_token = user.facebook_access_token
    graph = Koala::Facebook::API.new(facebook_access_token, ENV["FACEBOOK_APP_SECRET"])
    friends = graph.get_connections("me", "friends")

    still_has_friends = friends.present?
    friends_to_add = friends

    while still_has_friends
      add_friends(friends_to_add, user)

      next_page_of_friends = friends.next_page

      if next_page_of_friends.present?
        friends_to_add = next_page_of_friends
      else
        still_has_friends = false
      end
    end
  end

  def add_friends(facebook_friends, user)
    facebook_friends.each do |facebook_friend|
      friend = User.find_by(facebook_id: facebook_friend["id"])
      if friend
        friend.follow(user) unless friend.following?(user)
        user.follow(friend) unless user.following?(friend)
      end
    end
  end
end
