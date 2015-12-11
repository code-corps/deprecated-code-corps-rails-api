require "code_corps/scenario/generate_notifications_for_post_user_mentions"
require "code_corps/scenario/send_notification_emails"

class GeneratePostUserNotificationsWorker
  include Sidekiq::Worker

  def perform(post_id)
    post = Post.find(post_id)
    return if post.draft?
    CodeCorps::Scenario::GenerateNotificationsForPostUserMentions.new(post).call
    CodeCorps::Scenario::SendNotificationEmails.new(post).call
  end

end
