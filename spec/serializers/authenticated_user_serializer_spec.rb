require "rails_helper"

describe AuthenticatedUserSerializer, type: :serializer do
  context "individual resource representation" do
    let(:resource) do
      user = create(:user,
                    email: "user@mail.com",
                    name: "Josh Smith",
                    username: "joshsmith",
                    website: "example.com",
                    twitter: "@user",
                    biography: "Lorem ipsum",
                    facebook_id: "some_id",
                    facebook_access_token: "some_token")

      create_list(:user_skill, 2, user: user)

      user
    end

    let(:serializer) { AuthenticatedUserSerializer.new(resource) }
    let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer) }

    context "root" do
      subject do
        JSON.parse(serialization.to_json)["data"]
      end

      it "has an attributes object" do
        expect(subject["attributes"]).not_to be_nil
      end

      it "has a nil relationships object" do
        expect(subject["relationships"]).to be_nil
      end

      it "has an id" do
        expect(subject["id"]).to eq resource.id.to_s
      end

      it "has a type set to `users`" do
        expect(subject["type"]).to eq "users"
      end
    end

    context "attributes" do
      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has an 'email'" do
        expect(subject["email"]).to eq resource.email
      end

      it "has a 'username'" do
        expect(subject["username"]).to eq resource.username
      end

      it "has a 'name'" do
        expect(subject["name"]).to eq resource.name
      end

      it "has a 'twitter'" do
        expect(subject["twitter"]).to eq resource.twitter
      end

      it "has a 'website'" do
        expect(subject["website"]).to eq resource.website
      end

      it "has a 'biography'" do
        expect(subject["biography"]).to eq resource.biography
      end

      it "has a 'photo_thumb_url'" do
        expect(subject["photo_thumb_url"]).to eq resource.photo.url(:thumb)
      end

      it "has a 'photo_large_url'" do
        expect(subject["photo_large_url"]).to eq resource.photo.url(:large)
      end
    end
  end
end
