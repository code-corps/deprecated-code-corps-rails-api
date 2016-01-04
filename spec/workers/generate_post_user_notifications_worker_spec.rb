require 'rails_helper'

describe GeneratePostUserNotificationsWorker do

  let(:draft_post) { create(:post, :with_user_mentions, mention_count: 4, aasm_state: "draft") }
  let(:published_post) { create(:post, :with_user_mentions, mention_count: 4, aasm_state: "published") }

  context "when there are no pre-existing notifications" do
    context "when the post is a draft" do
      it "creates no notifications" do
        expect { GeneratePostUserNotificationsWorker.new.perform(draft_post.id) }.to_not change { ActionMailer::Base.deliveries.count }
      end

      it "sends no emails" do
        expect { GeneratePostUserNotificationsWorker.new.perform(draft_post.id) }.to_not change { Notification.sent.count }
      end
    end

    context "when the post is published" do
      it "creates correct number of notifications" do
        expect { GeneratePostUserNotificationsWorker.new.perform(published_post.id) }.to change { ActionMailer::Base.deliveries.count }.by 4
      end

      it "sends correct number of emails" do
        expect { GeneratePostUserNotificationsWorker.new.perform(published_post.id) }.to change { Notification.sent.count }.by 4
      end
    end
  end

  context "when there are pre-existing sent and read notifications" do
    before do
      create_list(:notification, 4, notifiable: published_post, aasm_state: "read")
      create_list(:notification, 3, notifiable: published_post, aasm_state: "sent")
    end

    it "creates correct number of notifications" do
      expect { GeneratePostUserNotificationsWorker.new.perform(published_post.id) }.to change { ActionMailer::Base.deliveries.count }.by 4
    end

    it "sends correct number of emails" do
      expect { GeneratePostUserNotificationsWorker.new.perform(published_post.id) }.to change { Notification.sent.count }.by 4
    end
  end
end
