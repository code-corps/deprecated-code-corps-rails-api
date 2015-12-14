module CodeCorps
  module Scenario
    class NotifyPusherOfCommentImage
      def initialize(comment_image)
        @comment_image = comment_image
      end

      def call
        Pusher.trigger(channel, 'comment_image_uploaded', data)
      end

      private

        def user_id
          @comment_image.user.id
        end

        def comment_id
          @comment_image.comment.id
        end

        def channel
          "private-user-#{user_id}"
        end

        def data
          {
            comment_id: comment_id,
            user_id: user_id,
            filename: @comment_image.filename,
            url: @comment_image.image.url
          }
        end
    end
  end
end
