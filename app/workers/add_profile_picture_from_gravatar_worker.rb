require "digest/md5"

class AddProfilePictureFromGravatarWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    photo_url = gravatar_photo_url(user)
    return unless photo_url
    user.photo = URI.parse(photo_url)
    user.save
  end

  private

  def gravatar_photo_url(user)
    hash = gravatar_hash_for(user)
    gravatar_url = "https://secure.gravatar.com/avatar/#{hash}?s=500&r=pg&d=404"
    gravatar_returns_error?(hash) ? nil : gravatar_url
  end

  def gravatar_hash_for(user)
    Digest::MD5.hexdigest(user.email)
  end

  def gravatar_returns_error?(hash)
    response = Faraday.get "https://secure.gravatar.com/avatar/#{hash}?d=404"

    response.body == "404 Not Found" ? true : false
  end
end
