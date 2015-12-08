require "rails_helper"
require "code_corps/scenario/generate_notification"

module CodeCorps
  module Scenario
    describe GenerateNotification do
      describe "#call" do

        it "creates a notification" do
          user = create(:user)
          post = create(:post)

          GenerateNotification.new(model, user).call

          notification = Notification.last
          expect(notification.model).to eq post
          expect(notification.user).to eq user
        end
      end
    end 
  end
end