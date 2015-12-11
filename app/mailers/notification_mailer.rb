class NotificationMailer < ActionMailer::Base
  default from: "notifications@example.com"

  def notify(notification)
    @user = notification.user
    @notifiable = notification.notifiable
    @author = @notifiable.user
    @type = @notifiable.class.to_s.downcase

    mail to: to_address, subject: subject
  end

  private

    def to_address
      @user.email
    end

    def subject
      "You have been mentioned in a #{@type}"
    end

end
