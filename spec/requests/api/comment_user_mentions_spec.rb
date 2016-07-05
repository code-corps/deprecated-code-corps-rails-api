require "rails_helper"

describe "CommentUserMentions API", :json_api do
  context "GET /comment_user_mentions/" do
    let(:comment_a) do
      comment = create(:comment)
      create_list(:comment_user_mention, 4, comment: comment)
      comment
    end

    let(:comment_b) do
      comment = create(:comment)
      create_list(:comment_user_mention, 1, comment: comment)
      comment
    end

    def make_request_for_comment(comment)
      get "#{host}/comment_user_mentions/", comment_id: comment.id
    end

    it "fetches mentions of specified status for specified comment" do
      make_request_for_comment(comment_a)
      expect(last_response.status).to eq 200
      expect(json).to(
        serialize_collection(comment_a.comment_user_mentions.all).
          with(CommentUserMentionSerializer)
      )
      make_request_for_comment(comment_b)
      expect(last_response.status).to eq 200
      expect(json).to(
        serialize_collection(comment_b.comment_user_mentions.all).
          with(CommentUserMentionSerializer)
      )
    end
  end
end
