require 'rails_helper'

describe GeneratePostUserNotificationsWorker do

  before do
    @post = create(:post, :with_user_mentions, mention_count: 4)
  end

  it "creates notifications and sends emails" do
    expect { GeneratePostUserNotificationsWorker.new.perform(@post.id) }.to change { ActionMailer::Base.deliveries.count }.by(4)
    expect(Notification.count).to eq 4
  end
end
