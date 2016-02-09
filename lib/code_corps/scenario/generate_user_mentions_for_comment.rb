module CodeCorps
  module Scenario
    class GenerateUserMentionsForComment
      def initialize(comment)
        @comment = comment
        @post = comment.post
      end

      def call
        result = []
        mentions = []

        @comment.body_preview.scan(/\B@((?:(?:(?:[^-\W]-?))*)(?:[^\/\W]\/?)?(?:(?:(?:[^-\W]-?))*)\w+)/) do |temp|
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
          existing_mentions = CommentUserMention.where(comment: @comment)
          if existing_mentions.present?
            existing_mentions.destroy_all
          end
          mentions.each do |m|
            CommentUserMention.create!(comment: @comment, post: @post, user: m[0], start_index: m[1], end_index: m[2], username: m[0].username)
          end
        end
      end
    end
  end
end
