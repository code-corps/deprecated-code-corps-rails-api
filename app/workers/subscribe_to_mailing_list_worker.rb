require "code_corps/adapters/mailing_list"

class SubscribeToMailingListWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    CodeCorps::Adapters::MailingList.new(user).subscribe
  end
end
