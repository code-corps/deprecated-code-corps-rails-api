require 'rails_helper'

describe NotifyPusherOfPostImageWorker do

  let(:gif_string) {
    file = File.open("#{Rails.root}/spec/sample_data/base64_images/gif.txt", 'r')
    open(file) { |io| io.read }
  }
  let(:post_image) { create(:post_image, :with_s3_image, filename: "jake.gif", base64_photo_data: gif_string) }

  it 'calls the NotifyPusherOfPostImage scenario' do
    expect_any_instance_of(CodeCorps::Scenario::NotifyPusherOfPostImage).to receive(:call).exactly(1).times
    NotifyPusherOfPostImageWorker.new.perform(post_image.id)
  end
end