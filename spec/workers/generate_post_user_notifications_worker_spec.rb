require 'rails_helper'

describe GeneratePostUserNotificationsWorker do

  before do
    @post = create(:post, :with_user_mentions, mention_count: 4)
  end

  context "when there are no pre-existing notifications" do
    it "creates correct number of notifications" do
      expect { GeneratePostUserNotificationsWorker.new.perform(@post.id) }.to change { ActionMailer::Base.deliveries.count }.by(4)
    end

    it "sends correct number of emails" do
      expect { GeneratePostUserNotificationsWorker.new.perform(@post.id) }.to change { Notification.sent.count }.by(4)
    end
  end

  context "when there are pre-existing sent and read notifications" do
    before do
      create_list(:notification, 4, notifiable: @post, aasm_state: "read")
      create_list(:notification, 3, notifiable: @post, aasm_state: "sent")
    end

    it "creates correct number of notifications" do
      expect { GeneratePostUserNotificationsWorker.new.perform(@post.id) }.to change { ActionMailer::Base.deliveries.count }.by(4)
    end

    it "sends correct number of emails" do
      expect { GeneratePostUserNotificationsWorker.new.perform(@post.id) }.to change { Notification.sent.count }.by(4)
    end
  end
end
