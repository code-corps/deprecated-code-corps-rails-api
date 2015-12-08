require 'rails_helper'

describe Post, :type => :model do
  describe "schema" do
    it { should have_db_column(:status).of_type(:string) }
    it { should have_db_column(:post_type).of_type(:string) }
    it { should have_db_column(:title).of_type(:string).with_options(null: false) }
    it { should have_db_column(:body).of_type(:text).with_options(null: false) }
    it { should have_db_column(:markdown).of_type(:text).with_options(null: false) }
    it { should have_db_column(:project_id).of_type(:integer).with_options(null: false) }
    it { should have_db_column(:user_id).of_type(:integer).with_options(null: false) }
    it { should have_db_column(:updated_at) }
    it { should have_db_column(:created_at) }
    it { should have_db_column(:post_likes_count).of_type(:integer) }
  end

  describe "relationships" do
    it { should have_many(:comments) }
    it { should belong_to(:project) }
    it { should belong_to(:user) }
    it { should have_many(:post_likes) }
    it { should have_many(:post_user_mentions) }
    it { should have_many(:comment_user_mentions) }
  end

  describe "validations" do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:project) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
    it { should validate_presence_of(:markdown) }
  end

  describe "behavior" do
    it { should define_enum_for(:status).with({ open: "open", closed: "closed" }) }
    it { should define_enum_for(:post_type).with({ idea: "idea", progress: "progress", task: "task", issue: "issue" }) }
  end

  describe ".post_like_counts" do
    let(:user) { create(:user) }
    let(:post) { create(:post) }

    context "when there is no PostLike" do
      it "should have the correct counter cache" do
        expect(post.likes_count).to eq 0
      end
    end

    context "when there is a PostLike" do
      it "should have the correct counter cache" do
        create(:post_like, user: user, post: post)
        expect(post.likes_count).to eq 1
      end
    end
  end

  describe "before_save" do
    it "converts markdown to html for the body" do
      post = create(:post, markdown: "# Hello World\n\nHello, world.")
      post.save

      post.reload
      expect(post.body).to eq "<h1>Hello World</h1>\n\n<p>Hello, world.</p>"
    end
  end

  describe "sequencing" do
    it "numbers posts for each project" do
      project = create(:project)
      first_post = create(:post, project: project)
      second_post = create(:post, project: project)

      expect(first_post.number).to eq 1
      expect(second_post.number).to eq 2
    end

    it "should not allow a duplicate number to be set for the same project" do
      project = create(:project)
      first_post = create(:post, project: project)
      expect { create(:post, project: project, number: 1) }.to raise_error ActiveRecord::RecordNotUnique
    end
  end

  describe "post user mentions" do
    context "when saving a post" do
      it "creates mentions only for existing users" do
        real_user = create(:user, username: "joshsmith")

        post = Post.create(
          project: create(:project),
          user: create(:user),
          markdown: "Hello @joshsmith and @someone_who_doesnt_exist",
          title: "Test"
        )

        post.reload
        mentions = post.post_user_mentions

        expect(mentions.count).to eq 1
        expect(mentions.first.user).to eq real_user
      end

      context "when usernames contain underscores" do
        it "creates mentions and not <em> tags" do
          underscored_user = create(:user, username: "a_real_username")

          post = Post.create(
            project: create(:project),
            user: create(:user),
            markdown: "Hello @a_real_username and @not_a_real_username",
            title: "Test"
          )

          post.reload
          mentions = post.post_user_mentions

          expect(mentions.count).to eq 1
          expect(mentions.first.user).to eq underscored_user
        end
      end
    end
  end
end