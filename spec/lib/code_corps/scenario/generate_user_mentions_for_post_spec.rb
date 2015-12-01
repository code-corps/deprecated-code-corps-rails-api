require "rails_helper"
require "code_corps/scenario/generate_user_mentions_for_post"

module CodeCorps
  module Scenario
    describe GenerateUserMentionsForPost do
      describe "#call" do

        let(:mentioned_username) { "joshsmith" }

        before do
          @mentioned_user = create(:user, username: mentioned_username)
        end
        

        it "creates user mentions" do
          original_post = create(:post, markdown: "Mentioning @joshsmith")
          post = GenerateUserMentionsForPost.new(original_post).call

          expect(post.id).to eq original_post.id

          mention = PostUserMention.last
          expect(mention.post).to eq post
          expect(mention.user).to eq @mentioned_user
          expect(mention.username).to eq mentioned_username
        end
      end
    end 
  end
end