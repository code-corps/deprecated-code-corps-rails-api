require "rails_helper"
require "code_corps/scenario/generate_user_mentions_for_comment"

module CodeCorps
  module Scenario
    describe GenerateUserMentionsForComment do
      describe "#call" do
        let(:user) { create(:user, username: "joshsmith") }
        let(:comment) { create(:comment) }

        before do
          # need to disable the default after save hook which generates mentions
          allow_any_instance_of(Comment).to receive(:generate_mentions)
        end

        it "creates user mentions for body" do
          comment.markdown = "Mentioning @#{user.username}"
          comment.save

          GenerateUserMentionsForComment.new(comment).call

          mention = CommentUserMention.last
          expect(mention.comment).to eq comment
          expect(mention.user).to eq user
          expect(mention.username).to eq user.username

          post = comment.post
          expect(post.comment_user_mentions).to include mention
        end

        it "does not fail when content is nil" do
          comment.markdown = nil
          comment.save
          expect { GenerateUserMentionsForComment.new(comment).call }.not_to raise_error
        end

        context "when mentions already exist" do
          before do
            create_list(:comment_user_mention, 2, comment: comment)
          end

          it "destroys previous mentions" do
            comment.body = "@#{user.username}"
            GenerateUserMentionsForComment.new(comment).call
            expect(comment.comment_user_mentions.count).to eq 1
          end
        end
      end
    end
  end
end
