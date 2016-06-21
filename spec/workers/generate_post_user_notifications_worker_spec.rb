require "rails_helper"

describe GeneratePostUserNotificationsWorker do
  let(:published_post) { create(:post, :published, :with_user_mentions, mention_count: 4) }

  context "when there are no pre-existing notifications" do
    it "creates correct number of notifications" do
      expect do
        GeneratePostUserNotificationsWorker.new.perform(published_post.id)
      end.to change { ActionMailer::Base.deliveries.count }.by 4
    end

    it "sends correct number of emails" do
      expect do
        GeneratePostUserNotificationsWorker.new.perform(published_post.id)
      end.to change { Notification.sent.count }.by 4
    end
  end

  context "when there are pre-existing sent and read notifications" do
    before do
      create_list(:notification, 4, notifiable: published_post, aasm_state: "read")
      create_list(:notification, 3, notifiable: published_post, aasm_state: "sent")
    end

    it "creates correct number of notifications" do
      expect do
        GeneratePostUserNotificationsWorker.new.perform(published_post.id)
      end.to change { ActionMailer::Base.deliveries.count }.by 4
    end

    it "sends correct number of emails" do
      expect do
        GeneratePostUserNotificationsWorker.new.perform(published_post.id)
      end.to change { Notification.sent.count }.by 4
    end
  end
end
