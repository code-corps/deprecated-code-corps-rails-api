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

      it "requires a 'post' to be specified" do
        params = { data: { type: "comments", attributes: { markdown: "Comment body" } } }
        authenticated_post "/comments", params, @token

        expect(last_response.status).to eq 422
        expect(json).to be_a_valid_json_api_error
        expect(json).to contain_an_error_of_type("VALIDATION_ERROR").with_message("Post can't be blank")
      end

      it "requires a 'body' to be specified" do
        params = { data: { type: "comments",
          attributes: {},
          relationships: { post: { data: { id: @post.id, type: "posts" } } }
        } }
        authenticated_post "/comments", params, @token

        expect(last_response.status).to eq 422
        expect(json).to be_a_valid_json_api_error
        expect(json).to contain_an_error_of_type("VALIDATION_ERROR").with_message("Body can't be blank")
      end

      context "when it succeeds" do
        context "as a draft" do
          before do
            params = { data: {
              type: "comments",
              attributes: { markdown: "Comment body" },
              relationships: {
                post: { data: { id: @post.id, type: "posts" } }
              }
            }}
            authenticated_post "/comments", params, @token
          end

          it "creates a comment" do
            comment = Comment.last
            expect(comment.body).to eq "<p>Comment body</p>"

            expect(comment.user_id).to eq @user.id
            expect(comment.post_id).to eq @post.id
          end

          it "returns the created comment" do
            comment_attributes = json.data.attributes
            expect(comment_attributes.body).to eq "<p>Comment body</p>"

            comment_relationships = json.data.relationships
            expect(comment_relationships.post).not_to be_nil

            comment_includes = json.included
            expect(comment_includes).to be_nil
          end

          it "sets user to current user" do
            comment_relationships = json.data.relationships
            expect(comment_relationships.user).not_to be_nil
            expect(comment_relationships.user.data.id).to eq @user.id.to_s
          end
        end

        context "when publishing" do
          before do
            params = { data: {
              type: "comments",
              attributes: { markdown: "Comment body", state: "published" },
              relationships: {
                post: { data: { id: @post.id, type: "posts" } }
              }
            }}
            authenticated_post "/comments", params, @token
          end

          it "creates a comment" do
            comment = Comment.last
            expect(comment.body).to eq "<p>Comment body</p>"

            expect(comment.user_id).to eq @user.id
            expect(comment.post_id).to eq @post.id
          end
        end
      end
    end
  end

  context "PATCH /comments/:id" do
    context "when unauthenticated" do
      it "should return a 401 with a proper error" do
        patch "#{host}/comments/1", { data: { type: "comments" } }
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      before do
        @user = create(:user, id: 1, email: "test_user@mail.com", password: "password")
        @post = create(:post, id: 2)
        @token = authenticate(email: "test_user@mail.com", password: "password")
      end

      context "when the comment doesn't exist" do
        it "responds with a 404" do
          authenticated_patch "/comments/1", { data: { type: "comments" } }, @token

          expect(last_response.status).to eq 404
          expect(json).to be_a_valid_json_api_error.with_id "RECORD_NOT_FOUND"
        end
      end

      context "when the comment does exist" do
        before do
          @comment = create(:comment, post: @post, user: @user)
        end

        context "when the attributes are valid" do
          context "when updating a draft" do
            before do
              valid_attributes = {
                data: {
                  attributes: {
                    markdown: "Edited body"
                  },
                  relationships: {
                    post: { data: { id: @post.id, type: "posts" } }
                  }
                }
              }
              authenticated_patch "/comments/#{@comment.id}", valid_attributes, @token
            end

            it "responds with a 200" do
              expect(last_response.status).to eq 200
            end

            it "responds with the comment, serialized with CommentSerializer" do
              expect(json).to serialize_object(@comment.reload).with(CommentSerializer)
            end

            it "updates the comment" do
              @comment.reload

              expect(@comment.markdown).to eq "Edited body"
              expect(@comment.body).to eq "<p>Edited body</p>"
            end
          end

          context "when publishing a comment" do
            before do
              valid_attributes = {
                data: {
                  attributes: {
                    markdown: "Edited body", state: "published"
                  },
                  relationships: {
                    post: { data: { id: @post.id, type: "posts" } }
                  }
                }
              }
              authenticated_patch "/comments/#{@comment.id}", valid_attributes, @token
            end

            it "updates the comment" do
              @comment.reload

              expect(@comment).to be_published
            end
          end

          context "when editing a published comment" do
            before do
              @comment.publish!

              valid_attributes = {
                data: {
                  attributes: {
                    markdown: "Edited body"
                  },
                  relationships: {
                    post: { data: { id: @post.id, type: "posts" } }
                  }
                }
              }
              authenticated_patch "/comments/#{@comment.id}", valid_attributes, @token
            end

            it "updates the comment" do
              @comment.reload

              expect(@comment).to be_edited
            end
          end
        end

        context "when the attributes are invalid" do
          before do
            invalid_attributes = {
              data: {
                attributes: {
                  markdown: ""
                },
                relationships: {
                  post: { data: { id: @post.id, type: "posts" } }
                }
              }
            }
            authenticated_patch "/comments/#{@comment.id}", invalid_attributes, @token
          end

          it "responds with a 422 validation error" do
            expect(last_response.status).to eq 422
            expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
          end
        end
      end
    end
  end
end
