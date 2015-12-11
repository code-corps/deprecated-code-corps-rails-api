require "rails_helper"
require "code_corps/scenario/notify_pusher_of_post_image"

module CodeCorps
  module Scenario
    describe NotifyPusherOfPostImage do

      let(:gif_string) {
        file = File.open("#{Rails.root}/spec/sample_data/base64_images/gif.txt", 'r')
        open(file) { |io| io.read }
      }
      let(:post_image) { create(:post_image, :with_s3_image, filename: "default-avatar.png", base64_photo_data: gif_string) }

      describe "#call" do

        it "notifies pusher", vcr: { cassette_name: "lib/code_corps/scenario/notify_pusher_of_post_image" } do
          data = {
            post_id: post_image.post.id,
            user_id: post_image.user.id,
            filename: post_image.filename,
            url: post_image.image.url
          }
          
          expect_any_instance_of(Pusher::Client).to receive(:trigger).with(
            "private-user-#{post_image.user.id}",
            'post_image_uploaded',
            data
          )

          NotifyPusherOfPostImage.new(post_image).call
        end
      end
    end
  end
end
