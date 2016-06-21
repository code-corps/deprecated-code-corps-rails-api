module CodeCorps
  module Scenario
    class GeneratePreviewMentions
      def initialize(preview)
        @preview = preview
      end

      attr_reader :preview

      def call
        ActiveRecord::Base.transaction do
          mentions.each do |m|
            PreviewUserMention.create!(
              preview: @preview,
              user: m[0],
              username: m[0].username,
              start_index: m[1],
              end_index: m[2],
            )
          end
        end
      end

      private

        def regex_matches
          regex = %r{\B@((?:(?:(?:[^-\W]-?))*)(?:[^\/\W]\/?)?(?:(?:(?:[^-\W]-?))*)\w+)}

          result = []

          content = preview.body

          return if content.nil?

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
