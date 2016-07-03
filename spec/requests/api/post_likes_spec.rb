require 'rails_helper'

describe "PostLikes API" do


  describe "POST /post_likes" do

    context "when unauthenticated" do
      it "responds with a 401" do
        post "#{host}/post_likes", { data: { } }
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:token) { authenticate(email: "josh@coderly.com", password: "password") }

      before do
        @user = create(:user, email: "josh@coderly.com", password: "password")
        @post = create(:post)
      end

      context "when creation is succesful" do
        before do
          authenticated_post "/post_likes", { data: { relationships: {
            post: { data: { type: "posts", id: @post.id } }
          } } }, token
        end

        it "responds with the created post_like" do
          expect(last_response.status).to eq 200
        end

        it "sets user to current user" do
          expect(json.data.relationships.user.data.id).to eq @user.id.to_s
          expect(PostLike.last.user).to eq @user
        end

        it "sets post to provided post" do
          expect(json.data.relationships.post.data.id).to eq @post.id.to_s
          expect(PostLike.last.post).to eq @post
        end

        it "includes user in the response" do
          expect(json.included).not_to be_nil

          included_users = json.included.select{ |i| i.type == "users" }
          expect(included_users.count).to eq 1
        end

        it "includes post in the response" do
          expect(json.included).not_to be_nil

          included_users = json.included.select{ |i| i.type == "posts" }
          expect(included_users.count).to eq 1
        end
      end

      context "when there's a post_like with that pair of user_id and skill_id already" do
        before do
          create(:post_like, user: @user, post: @post)
          authenticated_post "/post_likes", { data: { relationships: {
            post: { data: { type: "skills", id: @post.id } }
          } } }, token
        end

        it "fails with a validation error" do
          expect(last_response.status).to eq 422
          expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
        end
      end

      context "when there's no post with the specified id" do
        it "fails with a validation error" do
          authenticated_post "/post_likes", { data: { relationships: {
            post: { data: { type: "posts", id: 55 } }
          } } }, token

          expect(last_response.status).to eq 422
          expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
        end
      end

      it "requires a post to be specified" do
        authenticated_post "/post_likes", { data: { relationships: {} } }, token
        expect(last_response.status).to eq 422
        expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
      end
    end
  end

  describe "DELETE /post_likes/:id" do
    context "when unauthenticated" do
      it "responds with a 401" do
        delete "#{host}/post_likes/1"

        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:token) { authenticate(email: "josh@coderly.com", password: "password") }

      before do
        @user = create(:user, email: "josh@coderly.com", password: "password")
      end

      it "requires the user to be the current user" do
        create(:post_like, id: 1)

        authenticated_delete "/post_likes/1", {}, token

        expect(last_response.status).to eq 403
        expect(json).to be_a_valid_json_api_error.with_id "FORBIDDEN"
        expect(PostLike.count).to eq 1
      end

      context "when deletion is successful" do
        before do
          @post = create(:post)
          @like = create(:post_like, id: 1, user: @user)
          authenticated_delete "/post_likes/1", {}, token
        end

        it "responds with a 204" do
          expect(last_response.status).to eq 204
        end

        it "deletes the post_like" do
          expect(PostLike.exists?(@like.id)).to be false
        end

        it "leaves user and skill untouched" do
          expect(User.exists?(@user.id)).to be true
          expect(Post.exists?(@post.id)).to be true
        end
      end
    end
  end
end
