require "rails_helper"

describe NotifyPusherOfCommentImageWorker do
  let(:gif_string) do
    filename = "#{Rails.root}/spec/sample_data/base64_images/gif.txt"
    file = File.open(filename, "r")
    open(file, &:read)
  end
  
  let(:comment_image) do
    create(:comment_image, :with_s3_image,
      filename: "jake.gif", base64_photo_data: gif_string
    )
  end

  it "calls the NotifyPusherOCommentImage scenario" do
    expect_any_instance_of(CodeCorps::Scenario::NotifyPusherOfCommentImage).to receive(:call).exactly(1).times
    NotifyPusherOfCommentImageWorker.new.perform(comment_image.id)
  end
end
