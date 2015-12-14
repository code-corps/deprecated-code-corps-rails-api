require "rails_helper"

describe NotifyPusherOfPostImageWorker do
  let(:gif_string) do
    filename = "#{Rails.root}/spec/sample_data/base64_images/gif.txt"
    file = File.open(filename, "r")
    open(file, &:read)
  end

  let(:post_image) do
    create(:post_image, :with_s3_image,
      filename: "jake.gif", base64_photo_data: gif_string
    )
  end

  it "calls the NotifyPusherOfPostImage scenario" do
    expect_any_instance_of(
      CodeCorps::Scenario::NotifyPusherOfPostImage
    ).to receive(:call).exactly(1).times

    NotifyPusherOfPostImageWorker.new.perform(post_image.id)
  end
end
