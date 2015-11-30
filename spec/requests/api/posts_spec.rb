require "rails_helper"

describe "Posts API" do

  context "GET /posts" do
    before do
      create_list(:post, 13)
    end

    it "returns the first page of 10 records of no page number or size is specified" do
      get "#{host}/posts"
      expect(last_response.status).to eq 200
      expect(json.data.length).to eq 10
      expect(json.data.all? { |item| item.type == "posts" }).to be true
    end

    it "accepts different page numbers" do
      get "#{host}/posts", { page: { number: 1, size: 5 }}
      expect(json.data.length).to eq 5
      get "#{host}/posts", { page: { number: 3, size: 3 }}
      expect(json.data.length).to eq 3
    end

    it "accepts different page sizes" do
      get "#{host}/posts", { page: { number: 1, size: 3 }}
      expect(json.data.length).to eq 3
      get "#{host}/posts", { page: { number: 1, size: 4 }}
      expect(json.data.length).to eq 4
    end

    it "renders links in the response" do
      get "#{host}/posts", { page: { number: 2, size: 5 } }
      expect(json.links).not_to be_nil
      expect(json.links.self).not_to be_nil
      expect(json.links.first).not_to be_nil
      expect(json.links.prev).not_to be_nil
      expect(json.links.last).not_to be_nil
      expect(json.links.last).not_to be_nil
    end

    it "renders a meta in the response" do
      get "#{host}/posts", { page: { number: 2, size: 5 } }
      expect(json.meta).not_to be_nil
      expect(json.meta.total_records).to eq 13
      expect(json.meta.total_pages).to eq 3
      expect(json.meta.page_size).to eq 5
      expect(json.meta.current_page).to eq 2
    end
  end

  context "GET /posts/:id" do
    before do
      post = create(:post, id: 1, title: "Post")
      create_list(:comment, 5, post: post)
    end

    it "returns the specified post, with comments included" do
      get "#{host}/posts/1", {}
      expect(last_response.status).to eq 200

      expect(json.data.id).to eq "1"
      expect(json.data.type).to eq "posts"

      attributes = json.data.attributes
      expect(attributes.title).to eq "Post"

      comment_relationships = json.data.relationships.comments.data
      expect(comment_relationships.count).to eq 5

      expect(json.included).not_to be_nil

      comment_includes = json.included.select{ |i| i.type == "comments" }
      expect(comment_includes.count).to eq 5
    end
  end

  context "POST /posts" do

    context "when unauthenticated" do
      it "should return a 401 with a proper error" do
        post "#{host}/posts", { data: { type: "posts" } }
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      before do
        @user = create(:user, id: 1, email: "test_user@mail.com", password: "password")
        @project = create(:project, id: 2)
        @token = authenticate(email: "test_user@mail.com", password: "password")
      end


      it "requires a 'project' to be specified" do
        params = { data: { type: "posts", attributes: { title: "Post title", post_type: "issue" } } }
        authenticated_post "/posts", params, @token

        expect(last_response.status).to eq 422
        expect(json).to be_a_valid_json_api_error
        expect(json).to contain_an_error_of_type("VALIDATION_ERROR").with_message("Project can't be blank")
      end

      it "requires a 'title' to be specified" do
        params = { data: { type: "posts",
          attributes: { post_type: "issue" },
          relationships: { project: { data: { id: 2 } } }
        } }
        authenticated_post "/posts", params, @token

        expect(last_response.status).to eq 422
        expect(json).to be_a_valid_json_api_error
        expect(json).to contain_an_error_of_type("VALIDATION_ERROR").with_message("Title can't be blank")
      end

      it "does not require a 'post_type' to be specified" do
        params = { data: { type: "posts",
          attributes: { title: "Post title", markdown: "Post body" },
          relationships: { project: { data: { id: 2 } } }
        } }
        authenticated_post "/posts", params, @token

        expect(last_response.status).to eq 200
      end

      it "requires a 'body' to be specified" do
        params = { data: { type: "posts",
          attributes: { title: "Post title", post_type: "issue" },
          relationships: { project: { data: { id: 2 } } }
        } }
        authenticated_post "/posts", params, @token

        expect(last_response.status).to eq 422
        expect(json).to be_a_valid_json_api_error
        expect(json).to contain_an_error_of_type("VALIDATION_ERROR").with_message("Body can't be blank")
      end

      it "ignores the 'status' parameter" do
        params = { data: { type: "posts",
          attributes: { title: "Post title", post_type: "issue", status: "closed", markdown: "Post body" },
          relationships: { project: { data: { id: 2 } } }
        } }
        authenticated_post "/posts", params, @token

        expect(last_response.status).to eq 200
        expect(Post.last.open?).to be true
      end

      context "when it succeeds" do
        before do
          create(:project, id: 1)
          params = { data: {
            type: "posts",
            attributes: { title: "Post title", markdown: "Post body", post_type: "issue" },
            relationships: {
              project: { data: { id: 2, type: "projects" } }
            }
          }}
          authenticated_post "/posts", params, @token
        end

        it "creates a post" do
          post = Post.last
          expect(post.title).to eq "Post title"
          expect(post.body).to eq "<p>Post body</p>\n"
          expect(post.issue?).to be true

          expect(post.user_id).to eq 1
          expect(post.project_id).to eq 2
        end

        it "returns the created post" do
          post_attributes = json.data.attributes
          expect(post_attributes.title).to eq "Post title"
          expect(post_attributes.body).to eq "<p>Post body</p>\n"
          expect(post_attributes.post_type).to eq "issue"

          post_relationships = json.data.relationships
          expect(post_relationships.comments.data.length).to eq 0

          post_includes = json.included
          expect(post_includes).to be_nil
        end

        it "sets user to current user" do
          post_relationships = json.data.relationships
          expect(post_relationships.user).not_to be_nil
          expect(post_relationships.user.data.id).to eq "1"
        end

        it "sets status to 'open'" do
          post_attributes = json.data.attributes
          expect(post_attributes.status).to eq "open"
        end
      end
    end
  end
end
