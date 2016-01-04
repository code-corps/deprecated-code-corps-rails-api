module CodeCorps
  module Scenario
    class NotifyPusherOfPostImage
      def initialize(post_image)
        @post_image = post_image
      end

      def call
        Pusher.trigger(channel, 'post_image_uploaded', data)
      end

      private

        def user_id
          @post_image.user.id
        end

        def post_id
          @post_image.post.id
        end

        def channel
          "private-user-#{user_id}"
        end

        def data
          {
            post_id: post_id,
            user_id: user_id,
            filename: @post_image.filename,
            url: @post_image.image.url
          }
        end
    end
  end
end
