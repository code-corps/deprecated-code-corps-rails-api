require "code_corps/base64_image_decoder"

class UpdateProfilePictureWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    return unless user.base64_photo_data
    user.photo = Base64ImageDecoder.decode(user.base64_photo_data)
    user.base64_photo_data = nil
    user.save
  end
end