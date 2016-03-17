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

        it "creates user mentions for body_preview when previewing" do
          comment.markdown_preview = "Mentioning @#{user.username}"
          comment.update(false)

          GenerateUserMentionsForComment.new(comment).call

          mention = CommentUserMention.last
          expect(mention.comment).to eq comment
          expect(mention.user).to eq user
          expect(mention.username).to eq user.username

          post = comment.post
          expect(post.comment_user_mentions).to include mention
        end

        it "creates user mentions from body when publishing" do
          comment.markdown_preview = "Mentioning @#{user.username}"
          comment.update(true)

          GenerateUserMentionsForComment.new(comment).call

          mention = CommentUserMention.last
          expect(mention.comment).to eq comment
          expect(mention.user).to eq user
          expect(mention.username).to eq user.username

          post = comment.post
          expect(post.comment_user_mentions).to include mention
        end

        it "does not fail when content is nil" do
          comment.markdown_preview = nil
          comment.update(false)
          expect { GenerateUserMentionsForComment.new(comment).call }.not_to raise_error
        end

        context "when mentions already exist" do
          before do
            create_list(:comment_user_mention, 2, comment: comment, status: :published)
            create_list(:comment_user_mention, 3, comment: comment, status: :preview)
          end

          it "destroys preview mentions if preview was requested, leaves published mentions" do
            comment.publishing = false
            comment.body_preview = "@#{user.username}"
            GenerateUserMentionsForComment.new(comment).call
            expect(comment.comment_user_mentions.published.count).to eq 2
            expect(comment.comment_user_mentions.preview.count).to eq 1
          end

          it "destroys published mentions if publish was requested, leaves preview mentions" do
            comment.publishing = true
            comment.body = "@#{user.username}"
            GenerateUserMentionsForComment.new(comment).call
            expect(comment.comment_user_mentions.published.count).to eq 1
            expect(comment.comment_user_mentions.preview.count).to eq 3
          end
        end
      end
    end
  end
end
