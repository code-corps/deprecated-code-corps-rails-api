require "rails_helper"

describe "Comments API" do
  context "POST /comments" do

    context "when unauthenticated" do
      it "should return a 401 with a proper error" do
        post "#{host}/comments", { data: { type: "comments" } }
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      before do
        @user = create(:user, email: "test_user@mail.com", password: "password")
        @token = authenticate(email: "test_user@mail.com", password: "password")
        @post = create(:post)
      end

      def make_request
        authenticated_post "/comments", @params, @token
      end

      def make_request_with_sidekiq_inline
        Sidekiq::Testing::inline! { make_request }
      end

      it "requires a 'post' to be specified" do
        @params = { data: { type: "comments", attributes: { markdown: "Comment body" } } }
        make_request

        expect(last_response.status).to eq 422
        expect(json).to be_a_valid_json_api_error
        expect(json).to contain_an_error_of_type("VALIDATION_ERROR").with_message("Post can't be blank")
      end

      it "requires a 'body' to be specified" do
        @params = { data: { type: "comments",
          attributes: {},
          relationships: { post: { data: { id: 2, type: "posts" } } }
        } }
        make_request

        expect(last_response.status).to eq 422
        expect(json).to be_a_valid_json_api_error
        expect(json).to contain_an_error_of_type("VALIDATION_ERROR").with_message("Body can't be blank")
      end

      context "when it succeeds" do
        before do
          @mention_1 = create(:user)
          @mention_2 = create(:user)

          @params = { data: {
            type: "comments",
            attributes: { markdown: "@#{@mention_1.username} @#{@mention_2.username}" },
            relationships: {
              post: { data: { id: @post.id, type: "posts" } }
            }
          }}
        end

        it "creates a comment" do
          expect{ make_request }.to change{ Comment.count }.by 1
          comment = Comment.last
          expect(comment.markdown).to eq "@#{@mention_1.username} @#{@mention_2.username}"
          expect(comment.body).to eq "<p>@#{@mention_1.username} @#{@mention_2.username}</p>"

          expect(comment.post).to eq @post
          expect(comment.user).to eq @user
        end

        it "returns the created comment, serialized with CommentSerializer" do
          make_request

          expect(json).to serialize_object(Comment.last).with(CommentSerializer)
        end

        it "creates mentions" do
          expect{ make_request_with_sidekiq_inline }.to change { CommentUserMention.count }.by 2
        end

        it "creates notifications for each mentioned user" do
          expect{ make_request_with_sidekiq_inline }.to change{ Notification.sent.count }.by 2
        end

        it "sends mails for each mentioned user" do
          expect{ make_request_with_sidekiq_inline }.to change{ ActionMailer::Base.deliveries.count }.by 2
        end
      end
    end
  end
end
