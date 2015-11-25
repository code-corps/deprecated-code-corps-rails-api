require "rails_helper"

describe "Projects API" do

  context "GET /posts" do
    before do
      create_list(:post, 10)
    end

    it "returns a list of posts" do
      get "#{host}/posts"

      expect(last_response.status).to eq 200
      expect(json.data.length).to eq 10
      expect(json.data.all? { |item| item.type == "posts" }).to be true
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

end
