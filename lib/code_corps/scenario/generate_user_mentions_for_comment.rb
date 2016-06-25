module CodeCorps
  module Scenario
    class GenerateUserMentionsForComment
      def initialize(comment)
        @comment = comment
        @post = comment.post
      end

      attr_reader :comment, :post

      def call
        ActiveRecord::Base.transaction do
          destroy_existing_mentions
          mentions.each do |m|
            CommentUserMention.create!(
              comment: comment,
              post: post,
              user: m[0],
              username: m[0].username,
              start_index: m[1],
              end_index: m[2],
            )
          end
        end
      end

      private

        def destroy_existing_mentions
          existing_mentions = comment.comment_user_mentions
          existing_mentions.destroy_all if existing_mentions.present?
        end

        def regex_matches
          regex = %r{\B@((?:(?:(?:[^-\W]-?))*)(?:[^\/\W]\/?)?(?:(?:(?:[^-\W]-?))*)\w+)}

          result = []

          content = comment.body

          content.scan(regex) do |temp|
            username = temp.first
            start_index = Regexp.last_match.offset(0).first
            end_index = start_index + username.length
            result << [username, [start_index, end_index]]
          end

          result
        end

        def mentions
          matches = regex_matches
          users = User.where(username: matches.map(&:first))

          result = []

          matches.each do |r|
            users.each do |u|
              result << [u, r.last.first, r.last.last] if r.first == u.username
            end
          end

          result
        end
    end
  end
end
