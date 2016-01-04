require "rails_helper"
require "code_corps/scenario/send_notification_emails"

module CodeCorps
  module Scenario
    describe SendNotificationEmails do
      describe "#call" do
        def make_call
          SendNotificationEmails.new(@notifiable).call
        end

        context "when notifiable is a post" do
          before do
            @notifiable = create(:post)
            create_list(:notification, 2, notifiable: @notifiable, aasm_state: "pending")
            create_list(:notification, 3, notifiable: @notifiable, aasm_state: "sent")
            create_list(:notification, 4, notifiable: @notifiable, aasm_state: "read")
          end

          it "sends one email per pending notification" do
            expect{ make_call }.to change{ ActionMailer::Base.deliveries.count }.by 2
          end

          it "marks notifications as sent" do
            expect{ make_call }.to change{ Notification.sent.count }.by 2
          end
        end

        context "when notifiable is a comment" do
          before do
            @notifiable = create(:comment)
            create_list(:notification, 2, notifiable: @notifiable, aasm_state: "pending")
            create_list(:notification, 3, notifiable: @notifiable, aasm_state: "sent")
            create_list(:notification, 4, notifiable: @notifiable, aasm_state: "read")
          end

          it "sends one email per pending notification" do
            expect{ make_call }.to change{ ActionMailer::Base.deliveries.count }.by 2
          end

          it "marks notifications as sent" do
            expect{ make_call }.to change{ Notification.sent.count }.by 2
          end
        end

      end
    end
  end
end
