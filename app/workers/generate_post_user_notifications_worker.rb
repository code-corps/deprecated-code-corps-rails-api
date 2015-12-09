require "code_corps/scenario/generate_notifications_for_post_user_mentions"

class GeneratePostUserNotificationsWorker
  include Sidekiq::Worker

  def perform(post_id)
    post = Post.find(post_id)
    CodeCorps::GenerateNotificationsForPostUserMentions.new.perform(post)
  end

end
