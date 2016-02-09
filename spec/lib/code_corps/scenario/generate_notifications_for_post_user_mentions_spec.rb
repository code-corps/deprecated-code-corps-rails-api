require "rails_helper"
require "code_corps/scenario/generate_notifications_for_post_user_mentions"

module CodeCorps
  module Scenario
    describe GenerateNotificationsForPostUserMentions do
      describe "#call" do

        let(:user) { create(:user) }
        let(:post) { create(:post) }

        it "creates a notification" do
          create(:post_user_mention, user: user, post: post)
          GenerateNotificationsForPostUserMentions.new(post).call

          notification = Notification.last
          expect(Notification.all.count).to eq 1
          expect(notification.notifiable).to eq post
          expect(notification.user).to eq user
          expect(notification.pending?).to eq true
        end

        it "does not update existing notifications" do
          create(:post_user_mention, user: user, post: post)
          GenerateNotificationsForPostUserMentions.new(post).call

          notification = Notification.last
          notification.dispatch!

          GenerateNotificationsForPostUserMentions.new(post).call

          notification = Notification.last
          expect(Notification.all.count).to eq 1
          expect(notification.notifiable).to eq post
          expect(notification.user).to eq user
          expect(notification.sent?).to eq true
        end

        context "with duplicate mentions" do
          before do
            create(:post_user_mention, user: user, post: post)
            create(:post_user_mention, user: user, post: post)
          end

          it "generates a single notification" do
            GenerateNotificationsForPostUserMentions.new(post).call

            notification = Notification.last
            expect(Notification.all.count).to eq 1
            expect(notification.notifiable).to eq post
            expect(notification.user).to eq user
            expect(notification.pending?).to eq true
          end
        end
      end
    end
  end
end
