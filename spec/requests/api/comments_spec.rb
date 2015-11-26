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
        @user = create(:user, id: 1, email: "test_user@mail.com", password: "password")
        @token = authenticate(email: "test_user@mail.com", password: "password")
        @post = create(:post, id: 2)
      end


      it "requires a 'post' to be specified" do
        params = { data: { type: "comments", attributes: { body: "Comment body" } } }
        authenticated_post "/comments", params, @token

        expect(last_response.status).to eq 422
        expect(json).to be_a_valid_json_api_error
        expect(json).to contain_an_error_of_type("VALIDATION_ERROR").with_message("Post can't be blank")
      end

      it "requires a 'body' to be specified" do
        params = { data: { type: "comments",
          attributes: {},
          relationships: { post: { data: { id: 2, type: "posts" } } }
        } }
        authenticated_post "/comments", params, @token

        expect(last_response.status).to eq 422
        expect(json).to be_a_valid_json_api_error
        expect(json).to contain_an_error_of_type("VALIDATION_ERROR").with_message("Body can't be blank")
      end

      context "when it succeeds" do
        before do
          params = { data: {
            type: "comments",
            attributes: { body: "Comment body" },
            relationships: {
              post: { data: { id: 2, type: "posts" } }
            }
          }}
          authenticated_post "/comments", params, @token
        end

        it "creates a comment" do
          comment = Comment.last
          expect(comment.body).to eq "Comment body"

          expect(comment.user_id).to eq 1
          expect(comment.post_id).to eq 2
        end

        it "returns the created comment" do
          comment_attributes = json.data.attributes
          expect(comment_attributes.body).to eq "Comment body"

          comment_relationships = json.data.relationships
          expect(comment_relationships.post).not_to be_nil

          comment_includes = json.included
          expect(comment_includes).to be_nil
        end

        it "sets user to current user" do
          comment_relationships = json.data.relationships
          expect(comment_relationships.user).not_to be_nil
          expect(comment_relationships.user.data.id).to eq "1"
        end
      end
    end
  end
end
