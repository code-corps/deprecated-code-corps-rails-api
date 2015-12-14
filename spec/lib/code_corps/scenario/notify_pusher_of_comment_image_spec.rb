require "rails_helper"
require "code_corps/scenario/notify_pusher_of_comment_image"

module CodeCorps
  module Scenario
    describe NotifyPusherOfCommentImage do

      let(:gif_string) {
        file = File.open("#{Rails.root}/spec/sample_data/base64_images/gif.txt", 'r')
        open(file) { |io| io.read }
      }
      let(:comment_image) { create(:comment_image, :with_s3_image, filename: "jake.gif", base64_photo_data: gif_string) }

      describe "#call" do

        it "notifies pusher", vcr: { cassette_name: "lib/code_corps/scenario/notify_pusher_of_comment_image" } do
          data = {
            comment_id: comment_image.comment.id,
            user_id: comment_image.user.id,
            filename: comment_image.filename,
            url: comment_image.image.url
          }

          expect_any_instance_of(Pusher::Client).to receive(:trigger).with(
            "private-user-#{comment_image.user.id}",
            'comment_image_uploaded',
            data
          )

          NotifyPusherOfCommentImage.new(comment_image).call
        end
      end
    end
  end
end
