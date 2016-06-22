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

        it "creates user mentions for body" do
          post.markdown = "Mentioning @#{user.username}"
          post.save

          GenerateUserMentionsForPost.new(post).call

          mention = PostUserMention.last
          expect(mention.post).to eq post
          expect(mention.user).to eq user
          expect(mention.username).to eq user.username
        end

        it "does not fail when content is nil" do
          post.markdown = nil
          post.save
          expect { GenerateUserMentionsForPost.new(post).call }.not_to raise_error
        end

        context "when mentions already exist" do
          before do
            create_list(:post_user_mention, 2, post: post)
          end

          it "destroys previous mentions" do
            post.body = "@#{user.username}"
            GenerateUserMentionsForPost.new(post).call
            expect(post.post_user_mentions.count).to eq 1
          end
        end
      end
    end
  end
end
