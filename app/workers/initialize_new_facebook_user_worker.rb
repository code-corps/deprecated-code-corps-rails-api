class InitializeNewFacebookUserWorker
  include Sidekiq::Worker

  def perform(user_id)
    UpdateUsersLeaderboardsWorker.new.perform(user_id)
  end

end
