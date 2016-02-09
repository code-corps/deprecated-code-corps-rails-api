require "rails_helper"
require "code_corps/scenario/generate_user_mentions_for_comment"

module CodeCorps
  module Scenario
    describe GenerateUserMentionsForComment do
      describe "#call" do

        let(:mentioned_username) { "joshsmith" }

        before do
          @mentioned_user = create(:user, username: mentioned_username)
        end

        it "creates user mentions" do
          comment = build(:comment, markdown_preview: "Mentioning @joshsmith")
          comment.update

          GenerateUserMentionsForComment.new(comment).call

          mention = CommentUserMention.last
          expect(mention.comment).to eq comment
          expect(mention.user).to eq @mentioned_user
          expect(mention.username).to eq mentioned_username

          post = comment.post
          expect(post.comment_user_mentions).to include mention
        end
      end
    end
  end
end
