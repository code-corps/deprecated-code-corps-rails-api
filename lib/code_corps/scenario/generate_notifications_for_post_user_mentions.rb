module CodeCorps
  module Scenario
    class GenerateNotificationsForPostUserMentions
      def initialize(post)
        @post = post
      end

      def call
        ActiveRecord::Base.transaction do
          mentions = PostUserMention.includes(:user).where(post: @post)
          mentions.each do |mention|
            Notification.find_or_create_by!(notifiable: @post, user: mention.user)
          end
        end
      end
    end
  end
end
