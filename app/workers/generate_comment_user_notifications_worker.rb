require "code_corps/scenario/generate_notifications_for_comment_user_mentions"

class GenerateCommentUserNotificationsWorker
  include Sidekiq::Worker

  def perform(comment_id)
    comment = Comment.find(comment_id)
    CodeCorps::GenerateNotificationsForCommentUserMentions.new.perform(comment)
  end

end
