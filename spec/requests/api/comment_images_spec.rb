require "rails_helper"

describe "Comment Images API", :json_api do
  before do
    ActionMailer::Base.deliveries = []
  end

  feature "cors" do
    it "should be supported for POST" do
      post "#{host}/comments", nil, "HTTP_ORIGIN" => "*"
      expect(last_response).to have_proper_cors_headers

      cors_options("comment_images", :post)
      expect(last_response).to have_proper_preflight_options_response_headers
    end
  end

  context "POST /comment_images" do
    context "when unauthenticated" do
      it "should return a 401 with a proper error" do
        post "#{host}/comment_images", data: { type: "comment_images" }
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:gif_string) do
        file_path = "#{Rails.root}/spec/sample_data/base64_images/gif.txt"
        file = File.open(file_path, "r")
        open(file, &:read)
      end

      before do
        @user = create(:user, email: "test_user@mail.com", password: "password")
        @token = authenticate(email: "test_user@mail.com", password: "password")
      end

      context "when user owns the comment" do
        before do
          @comment = create(:comment, user: @user)
        end

        context "with valid data" do
          before do
            expect_any_instance_of(Analytics).to receive(:track_created_comment_image)

            params = { data: {
              type: "comment_images",
              attributes: {
                filename: "jake.gif",
                base64_photo_data: gif_string
              },
              relationships: {
                comment: { data: { id: @comment.id, type: "comments" } } }
            } }

            authenticated_post "/comment_images", params, @token
          end

          it "creates a valid comment image" do
            expect(CommentImage.last.filename).to eq "jake.gif"
            expect(CommentImage.last.user).to eq @user
            expect(CommentImage.last.comment).to eq @comment
          end

          it "notifies Pusher that the upload succeeded" do
            expect(NotifyPusherOfCommentImageWorker.jobs.size).to eq 1
          end

          it "responds with a 200" do
            expect(last_response.status).to eq 200
          end

          it "returns the created comment image using CommentImageSerializer" do
            expect(json).to serialize_object(CommentImage.last)
              .with(CommentImageSerializer)
          end
        end

        context "with invalid data" do
          it "fails when the base 64 string is empty" do
            params = { data: {
              type: "comment_images",
              attributes: { filename: "jake.gif" },
              relationships: {
                comment: { data: { id: @comment.id, type: "comments" } } }
            } }

            authenticated_post "/comment_images", params, @token

            expect(last_response.status).to eq 422

            expect(json).to be_a_valid_json_api_validation_error
              .with_message "can't be blank"
          end
        end
      end

      context "when user does not own the comment" do
        before do
          @comment = create(:comment)
          params = { data: {
            type: "comment_images",
            attributes: { filename: "jake.gif", base64_photo_data: gif_string },
            relationships: {
              comment: { data: { id: @comment.id, type: "comments" } } }
          } }

          authenticated_post "/comment_images", params, @token
        end

        it "responds with a 403 FORBIDDEN" do
          expect(last_response.status).to eq 403
          expect(json).to be_a_valid_json_api_error.with_id "FORBIDDEN"
        end
      end
    end
  end
end
