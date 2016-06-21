require "rails_helper"

describe "PostUserMentions API" do
  context "GET /post_user_mentions/" do
    let(:post_a) do
      post = create(:post)
      create_list(:post_user_mention, 4, post: post)
      post
    end

    let(:post_b) do
      post = create(:post)
      create_list(:post_user_mention, 1, post: post)
      post
    end

    def make_request_for_post(post)
      get "#{host}/post_user_mentions/", post_id: post.id
    end

    it "fetches mentions of specified status for specified post" do
      make_request_for_post(post_a)
      expect(last_response.status).to eq 200
      expect(json).to(
        serialize_collection(post_a.post_user_mentions.all).
          with(PostUserMentionSerializer)
      )

      make_request_for_post(post_b)
      expect(last_response.status).to eq 200
      expect(json).to(
        serialize_collection(post_b.post_user_mentions.all).
          with(PostUserMentionSerializer)
      )
    end
  end
end
