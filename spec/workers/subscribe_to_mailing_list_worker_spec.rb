require "rails_helper"

describe SubscribeToMailingListWorker do
  it "calls subscribe on an instance of CodeCorps::Adapters::MailingList" do
    user = create(:user)
    expect_any_instance_of(
      CodeCorps::Adapters::MailingList
    ).to receive(:subscribe).exactly(1).times

    SubscribeToMailingListWorker.new.perform(user.id)
  end
end
