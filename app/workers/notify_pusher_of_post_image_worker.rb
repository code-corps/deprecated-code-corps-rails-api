require "code_corps/scenario/notify_pusher_of_post_image"

class NotifyPusherOfPostImageWorker
  include Sidekiq::Worker

  def perform(post_image_id)
    post_image = PostImage.find(post_image_id)
    CodeCorps::Scenario::NotifyPusherOfPostImage.new(post_image).call
  end
end
