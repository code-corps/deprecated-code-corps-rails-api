module CodeCorps
  module Scenario
    class GenerateUserMentionsForPost
      def initialize(post)
        @post = post
      end

      def call
        result = []
        mentions = []

        @post.body_preview.scan(/\B@((?:(?:(?:[^-\W]-?))*)(?:[^\/\W]\/?)?(?:(?:(?:[^-\W]-?))*)\w+)/) do |temp|
          username = temp.first
          start_index = Regexp.last_match.offset(0).first
          end_index = start_index + username.length
          result << [ username, [start_index, end_index] ]
        end

        users = User.where(username: result.map(&:first))

        result.each do |r|
          users.each do |u|
            if r.first == u.username
              mentions << [u, r.last.first, r.last.last]
            end
          end
        end

        ActiveRecord::Base.transaction do
          existing_mentions = PostUserMention.where(post: @post)
          if existing_mentions.present?
            existing_mentions.destroy_all
          end
          mentions.each do |m|
            PostUserMention.create!(post: @post, user: m[0], start_index: m[1], end_index: m[2], username: m[0].username)
          end
        end
      end
    end
  end
end
