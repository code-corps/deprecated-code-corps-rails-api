class UpdateProfilePictureWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    return unless user.base_64_photo_data
    user.decode_image_data
    user.base_64_photo_data = nil
    user.save
  end
end