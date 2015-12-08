require "rails_helper"

describe "Posts API" do

  context "GET /projects/:id/posts" do
    context "when the project doesn't exist" do
      it "responds with a 404" do
        get "#{host}/projects/1/posts"
        expect(last_response.status).to eq 404
        expect(json).to be_a_valid_json_api_error.with_id "RECORD_NOT_FOUND"
      end
    end

    context "when the post doesn't exist" do
      before do
        @project = create(:project, owner: create(:organization))
      end

      it "responds with a 404" do
        get "#{host}/projects/#{@project.id}/posts/1"
        expect(last_response.status).to eq 404
        expect(json).to be_a_valid_json_api_error.with_id "RECORD_NOT_FOUND"
      end
    end

    context "when successful" do
      before do
        @project = create(:project, owner: create(:organization))
        create_list(:post, 13, project: @project)
      end

      context "when no page is specified" do
        before do
          get "#{host}/projects/#{@project.id}/posts"
        end

        it "responds with a 200" do
          expect(last_response.status).to eq 200
        end

        it "returns the first page of 10 Post records, serialized with PostSerializer" do
          expect(json).to serialize_collection(Post.page(1).per(10)).with(PostSerializer)
                            .with_links_to("#{host}/projects/#{@project.id}/posts")
                            .with_meta(total_records: 13, total_pages: 2, page_size: 10, current_page: 1)
        end
      end

      describe "specifying page parameters" do
        it "accepts different page numbers" do
          get "#{host}/projects/#{@project.id}/posts/", { page: { number: 1, size: 5 }}
          expect(json.data.length).to eq 5
          get "#{host}/projects/#{@project.id}/posts/", { page: { number: 3, size: 3 }}
          expect(json.data.length).to eq 3
        end

        it "accepts different page sizes" do
          get "#{host}/projects/#{@project.id}/posts/", { page: { number: 1, size: 3 }}
          expect(json.data.length).to eq 3
          get "#{host}/projects/#{@project.id}/posts/", { page: { number: 1, size: 4 }}
          expect(json.data.length).to eq 4
        end

        it "renders links in the response" do
          get "#{host}/projects/#{@project.id}/posts/", { page: { number: 2, size: 5 } }
          expect(json.links).not_to be_nil
          expect(json.links.self).not_to be_nil
          expect(json.links.first).not_to be_nil
          expect(json.links.prev).not_to be_nil
          expect(json.links.last).not_to be_nil
          expect(json.links.last).not_to be_nil
        end

        it "renders a meta in the response" do
          get "#{host}/projects/#{@project.id}/posts/", { page: { number: 2, size: 5 } }
          expect(json.meta).not_to be_nil
          expect(json.meta.total_records).to eq 13
          expect(json.meta.total_pages).to eq 3
          expect(json.meta.page_size).to eq 5
          expect(json.meta.current_page).to eq 2
        end
      end
    end
  end

  context "GET /projects/:project_id/posts/:number" do
    context "when the project doesn't exist" do
      it "responds with a 404" do
        get "#{host}/projects/1/posts/1"
        expect(last_response.status).to eq 404
        expect(json).to be_a_valid_json_api_error.with_id "RECORD_NOT_FOUND"
      end
    end

    context "when the post doesn't exist" do
      before do
        @project = create(:project, owner: create(:organization))
      end

      it "responds with a 404" do
        get "#{host}/projects/#{@project.id}/posts/1"
        expect(last_response.status).to eq 404
        expect(json).to be_a_valid_json_api_error.with_id "RECORD_NOT_FOUND"
      end
    end

    context "when successful" do
      before do
        @project = create(:project, owner: create(:organization))
        @post = create(:post, project: @project)
        create_list(:comment, 5, post: @post)
        get "#{host}/projects/#{@project.id}/posts/#{@post.number}"
      end

      it "responds with a 200" do
        expect(last_response.status).to eq 200
      end

      it "returns the post, serialized with PostSerializer, with comments included" do
        expect(json).to serialize_object(Post.last).with(PostSerializer).with_includes("comments")
      end
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

      it "does not accept a 'number' to be set directly" do
        params = { data: { type: "posts",
          attributes: { title: "Post title", markdown: "Post body", number: 3 },
          relationships: { project: { data: { id: 2 } } }
        } }
        authenticated_post "/posts", params, @token

        expect(last_response.status).to eq 200

        expect(json.data.attributes.number).to eq 1
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
