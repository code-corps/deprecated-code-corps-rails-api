require 'rails_helper'

describe GenerateCommentUserNotificationsWorker do

  let(:draft_comment) { create(:comment, :with_user_mentions, mention_count: 4,  aasm_state: "draft") }
  let(:published_comment) { create(:comment, :with_user_mentions, mention_count: 4,  aasm_state: "published") }

  context "when there are no pre-existing notifications" do
    context "when the comment is a draft" do
      it "creates no notifications" do
        expect { GenerateCommentUserNotificationsWorker.new.perform(draft_comment.id) }.not_to change { ActionMailer::Base.deliveries.count }
      end

      it "sends no emails" do
        expect { GenerateCommentUserNotificationsWorker.new.perform(draft_comment.id) }.not_to change { Notification.sent.count }
      end
    end

    context "when the comment is published" do
      it "creates correct number of notifications" do
        expect { GenerateCommentUserNotificationsWorker.new.perform(published_comment.id) }.to change { ActionMailer::Base.deliveries.count }.by 4
      end

      it "sends correct number of emails" do
        expect { GenerateCommentUserNotificationsWorker.new.perform(published_comment.id) }.to change { Notification.sent.count }.by 4
      end
    end
  end

  context "when there are pre-existing sent and read notifications" do
    before do
      create_list(:notification, 4, notifiable: published_comment, aasm_state: "read")
      create_list(:notification, 3, notifiable: published_comment, aasm_state: "sent")
    end

    it "creates correct number of notifications" do
      expect { GenerateCommentUserNotificationsWorker.new.perform(published_comment.id) }.to change { ActionMailer::Base.deliveries.count }.by 4
    end

    it "sends correct number of emails" do
      expect { GenerateCommentUserNotificationsWorker.new.perform(published_comment.id) }.to change { Notification.sent.count }.by 4
    end
  end
end
