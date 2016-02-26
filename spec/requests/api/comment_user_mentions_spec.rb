require "rails_helper"

describe "CommentUserMentions API" do
  context "GET /comment_user_mentions/" do
    let(:comment_a) do
      comment = create(:comment)
      create_list(:comment_user_mention, 4, comment: comment, status: :preview)
      create_list(:comment_user_mention, 3, comment: comment, status: :published)
      comment
    end

    let(:comment_b) do
      comment = create(:comment)
      create_list(:comment_user_mention, 1, comment: comment, status: :preview)
      create_list(:comment_user_mention, 2, comment: comment, status: :published)
      comment
    end

    def make_request_for_comment(comment, status)
      get "#{host}/comment_user_mentions/", status: status, comment_id: comment.id
    end

    it "fetches mentions of specified status for specified comment" do
      make_request_for_comment(comment_a, :preview)
      expect(last_response.status).to eq 200
      expect(json).to(
        serialize_collection(comment_a.comment_user_mentions.preview).
          with(CommentUserMentionSerializer)
      )

      make_request_for_comment(comment_a, :published)
      expect(last_response.status).to eq 200
      expect(json).to(
        serialize_collection(comment_a.comment_user_mentions.published).
          with(CommentUserMentionSerializer)
      )

      make_request_for_comment(comment_b, :preview)
      expect(last_response.status).to eq 200
      expect(json).to(
        serialize_collection(comment_b.comment_user_mentions.preview).
          with(CommentUserMentionSerializer)
      )

      make_request_for_comment(comment_b, :published)
      expect(last_response.status).to eq 200
      expect(json).to(
        serialize_collection(comment_b.comment_user_mentions.published).
          with(CommentUserMentionSerializer)
      )
    end
  end
end
