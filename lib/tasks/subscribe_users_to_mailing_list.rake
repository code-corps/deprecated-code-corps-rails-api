# lib/tasks/subscribe_users_to_mailing_list.rake
desc "Subscribe users to the mailing list"
task subscribe_users_to_mailing_list: :environment do
  User.find_each do |user|
    SubscribeToMailingListWorker.perform_async(user.id)
  end
end
