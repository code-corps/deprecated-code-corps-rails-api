module CodeCorps
  module Scenario
    class SendNotificationEmails

      def initialize(notifiable)
        @notifiable = notifiable
      end

      def call
        Notification.pending.includes(:user, :notifiable).where(notifiable: @notifiable).each do |notification|
          NotificationMailer.notify(notification).deliver_now
          notification.dispatch!
        end
      end
    end
  end
end
