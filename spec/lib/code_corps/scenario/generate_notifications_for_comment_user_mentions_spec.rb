require "rails_helper"
require "code_corps/scenario/generate_notifications_for_comment_user_mentions"

module CodeCorps
  module Scenario
    describe GenerateNotificationsForCommentUserMentions do
      describe "#call" do
        let(:user) { create(:user) }
        let(:comment) { create(:comment) }

        it "creates a notification" do
          create(:comment_user_mention, user: user, comment: comment)
          GenerateNotificationsForCommentUserMentions.new(comment).call

          notification = Notification.last
          expect(Notification.all.count).to eq 1
          expect(notification.notifiable).to eq comment
          expect(notification.user).to eq user
          expect(notification.pending?).to eq true
        end

        it "does not update existing notifications" do
          create(:comment_user_mention, user: user, comment: comment)
          GenerateNotificationsForCommentUserMentions.new(comment).call

          notification = Notification.last
          notification.dispatch!

          GenerateNotificationsForCommentUserMentions.new(comment).call

          notification = Notification.last
          expect(Notification.all.count).to eq 1
          expect(notification.notifiable).to eq comment
          expect(notification.user).to eq user
          expect(notification.sent?).to eq true
        end

        context "with duplicate mentions" do
          before do
            create(:comment_user_mention, user: user, comment: comment)
            create(:comment_user_mention, user: user, comment: comment)
          end

          it "generates a single notification" do
            GenerateNotificationsForCommentUserMentions.new(comment).call

            notification = Notification.last
            expect(Notification.all.count).to eq 1
            expect(notification.notifiable).to eq comment
            expect(notification.user).to eq user
            expect(notification.pending?).to eq true
          end
        end
      end
    end
  end
end
