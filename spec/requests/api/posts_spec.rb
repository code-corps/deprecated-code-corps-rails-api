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

    context "when successful" do
      before do
        @project = create(:project, organization: create(:organization))
        create_list(:post, 3, :published, project: @project, post_type: "issue")
        create_list(:post, 7, :published, project: @project, post_type: "task")
        create_list(:post, 3, :edited, project: @project, post_type: "idea")
      end

      it "returns active posts (published and edited)" do
        create_list(:post, 5, :draft, project: @project)
        get "#{host}/projects/#{@project.id}/posts"
        collection = Post.active.page(1).per(10)
        expect(json).to(
          serialize_collection(collection).
            with(PostSerializer).
            with_meta(total_records: 13, total_pages: 2, page_size: 10, current_page: 1)
        )
      end

      context "when no page is specified" do
        before do
          get "#{host}/projects/#{@project.id}/posts"
        end

        it "responds with a 200" do
          expect(last_response.status).to eq 200
        end

        it "returns the first page of 10 Post records, serialized with PostSerializer" do
          collection = Post.page(1).per(10)
          expect(json).to(
            serialize_collection(collection).
              with(PostSerializer).
              with_links_to("#{host}/projects/#{@project.id}/posts").
              with_meta(total_records: 13, total_pages: 2, page_size: 10, current_page: 1)
          )
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

      context "when 'post_type' parameter is specified" do
        it "only returns posts of those types, with proper meta" do
          get "#{host}/projects/#{@project.id}/posts", post_type: "issue,task"
          collection = Post.where(project: @project, post_type: ["issue", "task"])
          expect(json).to serialize_collection(collection).
            with(PostSerializer).
            with_meta(total_records: 10, total_pages: 1, page_size: 10, current_page: 1)
        end
      end

      it "returns posts in order by number" do
        get "#{host}/projects/#{@project.id}/posts"

        numbers_array = json.data.map(&:attributes).map(&:number)

        expect(numbers_array).to eq [13, 12, 11, 10, 9, 8, 7, 6, 5, 4]
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
        @project = create(:project, organization: create(:organization))
      end

      it "responds with a 404" do
        get "#{host}/projects/#{@project.id}/posts/1"
        expect(last_response.status).to eq 404
        expect(json).to be_a_valid_json_api_error.with_id "RECORD_NOT_FOUND"
      end
    end

    context "when successful" do
      before do
        @project = create(:project, organization: create(:organization))
        create(:user, username: "joshsmith")
        @post = create(:post, :published, project: @project, markdown: "Mentioning @joshsmith")
        create_list(:comment, 5, post: @post)
        get "#{host}/projects/#{@project.id}/posts/#{@post.number}"
      end

      it "responds with a 200" do
        expect(last_response.status).to eq 200
      end

      it "returns the post, serialized with PostSerializer, with users, comments and mentions included" do
        expect(json).to serialize_object(Post.last)
          .with(PostSerializer)
          .with_includes(["users", "comments", "post_user_mentions", "comment_user_mentions",
                          "comments_count"])
      end
    end
  end

  context "POST /posts" do
    context "when unauthenticated" do
      it "responds with a proper 401" do
        post "#{host}/posts", data: { type: "posts" }
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:user) { create :user, password: "password" }
      let(:organization) { create :organization }
      let(:project) { create :project, organization: organization }
      let(:token) { authenticate email: user.email, password: "password" }

      let(:mentioned_1) { create(:user) }
      let(:mentioned_2) { create(:user) }

      let(:params) do
        {
          data: {
            type: "posts",
            attributes: {
              title: "Post title",
              markdown_preview: "@#{mentioned_1.username} @#{mentioned_2.username}",
              post_type: "issue"
            },
            relationships: {
              project: { data: { id: project.id, type: "projects" } }
            }
          }
        }
      end

      before do
        create(
          :organization_membership,
          member: user, organization: organization, role: "contributor")

        ActionMailer::Base.deliveries.clear
      end

      def make_request(params)
        authenticated_post "/posts", params, token
      end

      def make_request_with_sidekiq_inline(params)
        Sidekiq::Testing.inline! { make_request params }
      end

      context "when requesting a preview" do
        it "creates a draft" do
          params[:data][:attributes][:preview] = true
          make_request_with_sidekiq_inline params

          post = Post.last

          # response is correct
          expect(last_response.status).to eq 200
          expect(json).to serialize_object(post).with(PostSerializer)

          # state is proper
          expect(post.draft?).to be true

          # attributes are properly set
          expect(post.title).to eq "Post title"
          expect(post.issue?).to be true
          expect(post.body).to be_nil
          expect(post.markdown).to be_nil
          expect(post.body_preview).to eq "<p>@#{mentioned_1.username} @#{mentioned_2.username}</p>"
          expect(post.markdown_preview).to eq "@#{mentioned_1.username} @#{mentioned_2.username}"

          # relationships are properly set
          expect(post.user_id).to eq user.id
          expect(post.project_id).to eq project.id

          # correct number of mentions was generated
          expect(PostUserMention.count).to eq 2

          # no notifications were sent or created
          expect(Notification.pending.count).to eq 0

          # no mails were sent
          expect(ActionMailer::Base.deliveries.count).to eq 0
        end
      end

      context "when requesting an actual save" do
        it "creates a published post" do
          make_request_with_sidekiq_inline params

          post = Post.last

          # response is correct
          expect(json).to serialize_object(post).with(PostSerializer)

          # state is proper
          expect(post.published?).to be true

          # attributes are properly set
          expect(post.title).to eq "Post title"
          expect(post.issue?).to be true
          expect(post.body).to eq "<p>@#{mentioned_1.username} @#{mentioned_2.username}</p>"
          expect(post.markdown).to eq "@#{mentioned_1.username} @#{mentioned_2.username}"
          expect(post.body_preview).to eq "<p>@#{mentioned_1.username} @#{mentioned_2.username}</p>"
          expect(post.markdown_preview).to eq "@#{mentioned_1.username} @#{mentioned_2.username}"

          # relationships are properly set
          expect(post.user_id).to eq user.id
          expect(post.project_id).to eq project.id

          # a mention was generated for each mentioned user
          expect(PostUserMention.count).to eq 2

          # a notification was sent for each generated mention
          expect(Notification.sent.count).to eq 2

          # an email was sent for each notification
          expect(ActionMailer::Base.deliveries.count).to eq 2
        end
      end

      context "when the attributes are invalid" do
        let(:invalid_attributes) do
          {
            data: {
              attributes: {
                title: nil, markdown_preview: nil
              },
              relationships: {
                project: { data: { id: project.id, type: "projects" } }
              }
            }
          }
        end

        it "responds with a 422 validation error" do
          authenticated_post "/posts", invalid_attributes, token
          expect(last_response.status).to eq 422
          expect(json).to be_a_valid_json_api_validation_error
        end
      end
    end
  end

  context "PATCH /posts/:id" do
    context "when unauthenticated" do
      it "responds with a proper 401" do
        patch "#{host}/posts/1"
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:user) { create :user, password: "password" }
      let(:token) { authenticate email: user.email, password: "password" }
      let(:organization) { create :organization }
      let(:project) { create :project, organization: organization }
      let(:mentioned_1) { create(:user) }
      let(:mentioned_2) { create(:user) }

      def make_request(params)
        authenticated_patch "/posts/#{post.id}", params, token
      end

      def make_request_with_sidekiq_inline(params)
        Sidekiq::Testing.inline! { make_request params }
      end

      let(:params) do
        {
          data: {
            id: post.id,
            type: "posts",
            attributes: {
              title: "Edited title",
              markdown_preview: "@#{mentioned_1.username} @#{mentioned_2.username}",
              post_type: "task"
            },
            relationships: {
              project: { data: { id: project.id, type: "projects" } }
            }
          }
        }
      end

      before do
        create(
          :organization_membership,
          member: user, organization: organization, role: "contributor")
      end

      context "when post does not exist" do
        it "responds with a 404" do
          authenticated_patch "/posts/bad_id", { data: { type: "posts" } }, token

          expect(last_response.status).to eq 404
          expect(json).to be_a_valid_json_api_error.with_id "RECORD_NOT_FOUND"
        end
      end

      context "when post is a draft" do
        let(:post) { create :post, :draft, project: project, user: user, post_type: "issue" }

        before do
          ActionMailer::Base.deliveries.clear
        end

        context "when requesting a preview" do
          before do
            params[:data][:attributes][:preview] = true
          end

          it "updates the draft" do
            make_request_with_sidekiq_inline params

            # response is correct
            expect(last_response.status).to eq 200
            expect(json).to serialize_object(post.reload).with(PostSerializer)

            # state is proper
            expect(post.draft?).to be true

            # attributes are properly set
            expect(post.title).to eq "Edited title"
            # post_type parameter was accepted
            expect(post.task?).to be true
            expect(post.body).to be_nil
            expect(post.markdown).to be_nil
            expect(post.body_preview).
              to eq "<p>@#{mentioned_1.username} @#{mentioned_2.username}</p>"
            expect(post.markdown_preview).to eq "@#{mentioned_1.username} @#{mentioned_2.username}"

            # post type was set
            expect(post.post_type).to eq "task"

            # relationships are properly set
            expect(post.user_id).to eq user.id
            expect(post.project_id).to eq project.id

            # correct number of mentions was generated
            expect(PostUserMention.count).to eq 2

            # no notifications were sent or created
            expect(Notification.pending.count).to eq 0

            # no mails were sent
            expect(ActionMailer::Base.deliveries.count).to eq 0
          end
        end

        context "when requesting an actual save" do
          it "updates and publishes post" do
            make_request_with_sidekiq_inline params

            # response is correct
            expect(last_response.status).to eq 200
            expect(json).to serialize_object(post.reload).with(PostSerializer)

            # state is proper
            expect(post.published?).to be true

            # attributes are properly set
            expect(post.title).to eq "Edited title"
            # post_type parameter was accepted
            expect(post.task?).to be true
            expect(post.body).to eq "<p>@#{mentioned_1.username} @#{mentioned_2.username}</p>"
            expect(post.markdown).to eq "@#{mentioned_1.username} @#{mentioned_2.username}"
            expect(post.body_preview).
              to eq "<p>@#{mentioned_1.username} @#{mentioned_2.username}</p>"
            expect(post.markdown_preview).to eq "@#{mentioned_1.username} @#{mentioned_2.username}"

            # relationships are properly set
            expect(post.user_id).to eq user.id
            expect(post.project_id).to eq project.id

            # a mention was generated for each mentioned user
            expect(PostUserMention.count).to eq 2

            # a notification was sent for each generated mention
            expect(Notification.sent.count).to eq 2

            # an email was sent for each notification
            expect(ActionMailer::Base.deliveries.count).to eq 2
          end
        end
      end

      context "when post is published" do
        let(:post) { create :post, :published, project: project, user: user, post_type: :issue }

        context "when requesting a preview" do
          before do
            params[:data][:attributes][:preview] = true
          end

          it "updates the published post" do
            make_request_with_sidekiq_inline params

            # post_type parameter was ignored
            expect(post.issue?).to be true

            # response is correct
            expect(last_response.status).to eq 200
            expect(json).to serialize_object(post.reload).with(PostSerializer)

            # state is proper
            expect(post.published?).to be true
          end
        end

        context "when requesting an actual save" do
          it "updates and post and sets it to edited state" do
            params[:data][:attributes][:publish] = true
            make_request_with_sidekiq_inline params

            # post_type parameter was ignored
            expect(post.task?).to be false

            # response is correct
            expect(last_response.status).to eq 200
            expect(json).to serialize_object(post.reload).with(PostSerializer)

            # state is proper
            expect(post.edited?).to be true
          end
        end
      end

      context "when post exists and markdown_preview param is an empty string" do
        let(:post) { create :post, :draft, project: project, user: user, post_type: "issue" }

        before do
          params[:data][:attributes][:preview] = true
          params[:data][:attributes][:markdown_preview] = ""
        end

        it "overwrites the body_preview with new markdown data" do
          make_request_with_sidekiq_inline params
          expect(last_response.status).to eq 200

          post.reload
          expect(post.markdown_preview).to eq ""
          expect(post.body_preview).to eq ""

          expect(json.data.attributes.markdown_preview).to eq ""
          expect(json.data.attributes.body_preview).to eq ""
        end
      end
    end
  end
end
