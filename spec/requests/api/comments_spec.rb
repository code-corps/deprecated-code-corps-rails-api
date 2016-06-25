require "rails_helper"

describe "Comments API" do
  feature "cors" do
    it "should be supported for POST" do
      post "#{host}/comments", nil, "HTTP_ORIGIN" => "*"
      expect(last_response).to have_proper_cors_headers

      cors_options("comments", :post)
      expect(last_response).to have_proper_preflight_options_response_headers
    end

    it "should be supported for PATCH" do
      post "#{host}/comments", nil, "HTTP_ORIGIN" => "*"
      expect(last_response).to have_proper_cors_headers

      cors_options("comments", :patch)
      expect(last_response).to have_proper_preflight_options_response_headers
    end
  end

  context "GET /comments" do
    before do
      create(:comment, id: 1)
      create(:comment, id: 2)
      create(:comment, id: 3)
    end

    def make_request(params = {})
      get "#{host}/comments", params
    end

    it "requires the id filter" do
      make_request
      expect(last_response.status).to eq 400 # bad request
    end

    it "returns a collection of comments based on specified ids" do
      make_request(filter: { id: "1,2" })
      expect(last_response.status).to eq 200
      expect(json).
        to serialize_collection(Comment.where(id: [1, 2])).
        with(CommentSerializer)
    end
  end

  context "GET /posts/:id/comments" do
    context "when unauthenticated" do
      before do
        @post = create(:post, id: 2)
        create_list(:comment, 3, :published, post: @post)

        get "#{host}/posts/#{@post.id}/comments"
      end

      it "responds with a 200" do
        expect(last_response.status).to eq 200
      end

      it "responds with active comments, serialized with CommentSerializer" do
        collection = @post.comments
        expect(json).to(
          serialize_collection(collection).
          with(CommentSerializer)
        )
      end
    end
  end

  context "POST /comments" do
    context "when unauthenticated" do
      it "responds with a proper 401" do
        post "#{host}/comments", data: { type: "comments" }
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:user) { create :user, password: "password" }
      let(:users_post) { create :post, user: user }
      let(:token) { authenticate email: user.email, password: "password" }

      let(:mentioned_1) { create(:user) }
      let(:mentioned_2) { create(:user) }

      def make_request(params)
        authenticated_post "/comments", params, token
      end

      def make_request_with_sidekiq_inline(params)
        Sidekiq::Testing.inline! { make_request params }
      end

      let(:params) do
        {
          data: {
            type: "comments",
            attributes: {
              markdown: "@#{mentioned_1.username} @#{mentioned_2.username}"
            },
            relationships: {
              post: { data: { id: users_post.id, type: "posts" } }
            }
          }
        }
      end

      before do
        ActionMailer::Base.deliveries.clear
      end

      context "when the attributes are valid" do
        it "creates a published comment" do
          make_request_with_sidekiq_inline params

          comment = Comment.last

          # response is correct
          expect(json).to serialize_object(comment).with(CommentSerializer)

          # state is proper
          expect(comment.published?).to be true

          # attributes are properly set
          expect(comment.body).to eq "<p>@#{mentioned_1.username} @#{mentioned_2.username}</p>"
          expect(comment.markdown).to eq "@#{mentioned_1.username} @#{mentioned_2.username}"
          expect(comment.body).to eq "<p>@#{mentioned_1.username} @#{mentioned_2.username}</p>"
          expect(comment.markdown).to eq "@#{mentioned_1.username} @#{mentioned_2.username}"

          # relationships are properly set
          expect(comment.user_id).to eq user.id
          expect(comment.post_id).to eq users_post.id

          # a mention was generated for each mentioned user
          expect(CommentUserMention.count).to eq 2

          # a notification was sent for each generated mention
          expect(Notification.sent.count).to eq 2

          # an email was sent for each notification
          expect(ActionMailer::Base.deliveries.count).to eq 2
        end

        context "when markdown is an empty string" do
          before do
            params[:data][:attributes][:markdown] = ""
          end

          it "responds with a validation error" do
            make_request_with_sidekiq_inline params
            expect(last_response.status).to eq 422
          end
        end
      end

      context "when the attributes are invalid" do
        let(:invalid_attributes) do
          {
            data: {
              attributes: {
                title: "", markdown: ""
              },
              relationships: {
                post: { data: { id: users_post.id, type: "posts" } }
              }
            }
          }
        end

        it "responds with a 422 validation error" do
          make_request invalid_attributes
          expect(last_response.status).to eq 422
          expect(json).to be_a_valid_json_api_validation_error
        end
      end
    end
  end

  context "PATCH /comments/:id" do
    context "when unauthenticated" do
      it "responds with a proper 401" do
        patch "#{host}/comments/1"
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:user) { create :user, password: "password" }
      let(:token) { authenticate email: user.email, password: "password" }
      let(:post) { create :post, user: user }
      let(:mentioned_1) { create(:user) }
      let(:mentioned_2) { create(:user) }

      def make_request(params)
        authenticated_patch "/comments/#{comment.id}", params, token
      end

      def make_request_with_sidekiq_inline(params)
        Sidekiq::Testing.inline! { make_request params }
      end

      let(:params) do
        {
          data: {
            id: comment.id,
            type: "comments",
            attributes: {
              title: "Edited title",
              markdown: "@#{mentioned_1.username} @#{mentioned_2.username}",
              state: "edited"
            }
          }
        }
      end

      context "when comment does not exist" do
        it "responds with a 404" do
          authenticated_patch "/comments/bad_id", { data: { type: "comments" } }, token

          expect(last_response.status).to eq 404
          expect(json).to be_a_valid_json_api_error.with_id "RECORD_NOT_FOUND"
        end
      end

      context "when comment is published" do
        let(:comment) { create :comment, :published, post: post, user: user }

        it "updates and sets it to edited state" do
          make_request_with_sidekiq_inline params

          # response is correct
          expect(last_response.status).to eq 200
          expect(json).to serialize_object(comment.reload).with(CommentSerializer)

          # state is proper
          expect(comment.edited?).to be true
        end
      end

      context "when comment exists and markdown param is an empty string" do
        let(:comment) { create :comment, post: post, user: user }

        before do
          params[:data][:attributes][:markdown] = ""
        end

        it "does not overwrite the markdown or body" do
          make_request_with_sidekiq_inline params
          expect(last_response.status).to eq 422
          expect(json).to be_a_valid_json_api_validation_error

          comment.reload
          expect(comment.markdown).to_not eq ""
          expect(comment.body).to_not eq ""
        end
      end
    end
  end
end
