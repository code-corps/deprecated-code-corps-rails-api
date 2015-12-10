require 'rails_helper'

describe GenerateCommentUserNotificationsWorker do

  before do
    @comment = create(:comment, :with_user_mentions, mention_count: 4)
  end

  context "when there are no pre-existing notifications" do
    it "creates correct number of notifications" do
      expect { GenerateCommentUserNotificationsWorker.new.perform(@comment.id) }.to change { ActionMailer::Base.deliveries.count }.by(4)
    end

    it "sends correct number of emails" do
      expect { GenerateCommentUserNotificationsWorker.new.perform(@comment.id) }.to change { Notification.sent.count }.by(4)
    end
  end

  context "when there are pre-existing sent and read notifications" do
    before do
      create_list(:notification, 4, notifiable: @comment, aasm_state: "read")
      create_list(:notification, 3, notifiable: @comment, aasm_state: "sent")
    end

    it "creates correct number of notifications" do
      expect { GenerateCommentUserNotificationsWorker.new.perform(@comment.id) }.to change { ActionMailer::Base.deliveries.count }.by(4)
    end

    it "sends correct number of emails" do
      expect { GenerateCommentUserNotificationsWorker.new.perform(@comment.id) }.to change { Notification.sent.count }.by(4)
    end
  end
end
