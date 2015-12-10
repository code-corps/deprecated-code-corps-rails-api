require "code_corps/scenario/generate_notifications_for_comment_user_mentions"

class GenerateCommentUserNotificationsWorker
  include Sidekiq::Worker

  def perform(comment_id)
    comment = Comment.find(comment_id)
    CodeCorps::Scenario::GenerateNotificationsForCommentUserMentions.new(comment).call

    Notification.pending.where(notifiable: comment).each do |notification|
      NotificationMailer.notify(notification).deliver_now
      notification.dispatch!
    end
  end

end
