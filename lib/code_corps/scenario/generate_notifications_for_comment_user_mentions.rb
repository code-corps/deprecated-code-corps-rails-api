module CodeCorps
  module Scenario
    class GenerateNotificationsForCommentUserMentions
      def initialize(comment)
        @comment = comment
      end

      def call
        ActiveRecord::Base.transaction do
          mentions = CommentUserMention.where(comment: @comment)
          mentions.each do |mention|
            Notification.find_or_create_by!(notifiable: @comment, user: mention.user)
          end
        end
      end
    end
  end
end
