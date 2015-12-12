require 'rails_helper'

describe NotifyPusherOfCommentImageWorker do

  let(:gif_string) {
    file = File.open("#{Rails.root}/spec/sample_data/base64_images/gif.txt", 'r')
    open(file) { |io| io.read }
  }
  let(:comment_image) { create(:comment_image, :comment_with_s3_image, filename: "jake.gif", base64_photo_data: gif_string) }

  it 'calls the NotifyPusherOCommentImage scenario' do
    expect_any_instance_of(CodeCorps::Scenario::NotifyPusherOfCommentImage).to receive(:call).exactly(1).times
    NotifyPusherOfCommentImageWorker.new.perform(comment_image.id)
  end
end