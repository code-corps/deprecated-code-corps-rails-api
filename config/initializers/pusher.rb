Pusher.app_id = ENV['PUSHER_APP_ID']
Pusher.key = ENV['PUSHER_KEY']
Pusher.secret = ENV['PUSHER_SECRET']

if Rails.env.test? && ENV["PUSHER_FAKE"]
  require "pusher-fake/support/base"
end
