require "code_corps/scenario/generate_notifications_for_comment_user_mentions"
require "code_corps/scenario/send_notification_emails"

class GenerateCommentUserNotificationsWorker
  include Sidekiq::Worker

  def perform(comment_id)
    comment = Comment.find(comment_id)
    return if comment.draft?
    CodeCorps::Scenario::GenerateNotificationsForCommentUserMentions.new(comment).call
    CodeCorps::Scenario::SendNotificationEmails.new(comment).call
  end
end
