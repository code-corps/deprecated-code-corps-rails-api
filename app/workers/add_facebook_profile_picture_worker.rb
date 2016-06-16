class AddFacebookProfilePictureWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    photo_url = facebook_photo_url(user)
    return unless photo_url
    user.photo = URI.parse(photo_url)
    user.save
    analytics_for(user).track_added_profile_picture_from_facebook
  end

  private

    def analytics_for(user)
      @analytics_for ||= Analytics.new(user)
    end

    def facebook_photo_url(user)
      facebook_access_token = user.facebook_access_token
      graph = Koala::Facebook::API.new(facebook_access_token, ENV['FACEBOOK_APP_SECRET'])
      graph.get_picture('me', type: "large")
    end
end
