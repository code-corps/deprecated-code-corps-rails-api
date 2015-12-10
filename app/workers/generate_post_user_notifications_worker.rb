require "code_corps/scenario/generate_notifications_for_post_user_mentions"

class GeneratePostUserNotificationsWorker
  include Sidekiq::Worker

  def perform(post_id)
    post = Post.find(post_id)
    CodeCorps::Scenario::GenerateNotificationsForPostUserMentions.new(post).call

    Notification.pending.where(notifiable: post).each do |notification|
      NotificationMailer.notify(notification).deliver_now
      notification.dispatch!
    end
  end

end
