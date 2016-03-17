require "rails_helper"
require "code_corps/scenario/generate_user_mentions_for_post"

module CodeCorps
  module Scenario
    describe GenerateUserMentionsForPost do
      describe "#call" do
        let(:user) { create(:user, username: "joshsmith") }
        let(:post) { create(:post) }

        before do
          # need to skip the default hook for generating mentions
          allow_any_instance_of(Post).to receive(:generate_mentions)
        end

        it "creates user mentions for body_preview when previewing" do
          post.markdown_preview = "Mentioning @#{user.username}"
          post.update(false)

          GenerateUserMentionsForPost.new(post).call

          mention = PostUserMention.last
          expect(mention.post).to eq post
          expect(mention.user).to eq user
          expect(mention.username).to eq user.username
        end

        it "creates user mentions from body when publishing" do
          post.markdown_preview = "Mentioning @#{user.username}"
          post.update(true)

          GenerateUserMentionsForPost.new(post).call

          mention = PostUserMention.last
          expect(mention.post).to eq post
          expect(mention.user).to eq user
          expect(mention.username).to eq user.username
        end

        it "does not fail when content is nil" do
          post.markdown_preview = nil
          post.update(false)
          expect { GenerateUserMentionsForPost.new(post).call }.not_to raise_error
        end

        context "when mentions already exist" do
          before do
            create_list(:post_user_mention, 2, post: post, status: :published)
            create_list(:post_user_mention, 3, post: post, status: :preview)
          end

          it "destroys preview mentions if preview was requested, leaves published mentions" do
            post.publishing = false
            post.body_preview = "@#{user.username}"
            GenerateUserMentionsForPost.new(post).call
            expect(post.post_user_mentions.published.count).to eq 2
            expect(post.post_user_mentions.preview.count).to eq 1
          end

          it "destroys published mentions if publish was requested, leaves preview mentions" do
            post.publishing = true
            post.body = "@#{user.username}"
            GenerateUserMentionsForPost.new(post).call
            expect(post.post_user_mentions.published.count).to eq 1
            expect(post.post_user_mentions.preview.count).to eq 3
          end
        end
      end
    end
  end
end
