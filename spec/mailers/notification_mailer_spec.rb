require "spec_helper"

describe NotificationMailer do
  describe "notify" do
    let(:notification) { create(:notification) }
    let(:mail) { NotificationMailer.notify(notification) }
    let(:author) { notification.notifiable.user}

    it "renders the subject" do
      expect(mail.subject).to eql("You have been mentioned in a post")
    end

    it "renders the receiver email" do
      expect(mail.to).to eql([notification.user.email])
    end

    it "renders the sender email" do
      expect(mail.from).to eql(["notifications@example.com"])
    end

    it "renders author name in the body" do
      expect(mail.body.encoded).to match(author.username)
    end
  end
end
