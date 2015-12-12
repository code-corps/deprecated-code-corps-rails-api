require "code_corps/scenario/notify_pusher_of_comment_image"

class NotifyPusherOfCommentImageWorker
  include Sidekiq::Worker

  def perform(comment_image_id)
    comment_image = CommentImage.find(comment_image_id)
    CodeCorps::Scenario::NotifyPusherOfCommentImage.new(comment_image).call
  end
end
