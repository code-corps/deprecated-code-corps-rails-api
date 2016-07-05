require "rails_helper"

describe UserSerializerWithoutIncludes, type: :serializer do

  context "individual resource representation" do
    let(:resource) do
      user = create(:user,
                    email: "user@mail.com",
                    first_name: "Josh",
                    last_name: "Smith",
                    username: "joshsmith",
                    website: "example.com",
                    twitter: "user",
                    biography: "Lorem ipsum",
                    facebook_id: "some_id",
                    facebook_access_token: "some_token")

      create_list(:user_skill, 10, user: user)
      user
    end

    let(:serializer) { UserSerializerWithoutIncludes.new(resource) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

    context "root" do
      subject do
        JSON.parse(serialization.to_json)["data"]
      end

      it "has an attributes object" do
        expect(subject["attributes"]).not_to be_nil
      end

      it "has a relationships object" do
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
        expect(subject["email"]).to_not be_nil
      end

      it "has a 'username'" do
        expect(subject["username"]).to eq resource.username
        expect(subject["username"]).to_not be_nil
      end

      it "has a 'first_name'" do
        expect(subject["first_name"]).to eq resource.first_name
        expect(subject["first_name"]).to_not be_nil
      end

      it "has a 'last_name'" do
        expect(subject["last_name"]).to eq resource.last_name
        expect(subject["last_name"]).to_not be_nil
      end

      it "has a 'name'" do
        expect(subject["name"]).to eq resource.name
        expect(subject["name"]).to_not be_nil
      end

      it "has a 'twitter'" do
        expect(subject["twitter"]).to eq resource.twitter
        expect(subject["twitter"]).to_not be_nil
      end

      it "has a 'website'" do
        expect(subject["website"]).to eq resource.website
        expect(subject["website"]).to_not be_nil
      end

      it "has a 'biography'" do
        expect(subject["biography"]).to eq resource.biography
        expect(subject["biography"]).to_not be_nil
      end

      it "has a 'facebook_id'" do
        expect(subject["facebook_id"]).to eq resource.facebook_id
        expect(subject["facebook_id"]).to_not be_nil
      end

      it "has a 'facebook_access_token'" do
        expect(subject["facebook_access_token"]).to eq resource.facebook_access_token
        expect(subject["facebook_access_token"]).to_not be_nil
      end

      it "has a 'photo_thumb_url'" do
        expect(subject["photo_thumb_url"]).to eq resource.photo.url(:thumb)
        expect(subject["photo_thumb_url"]).to_not be_nil
      end

      it "has a 'photo_large_url'" do
        expect(subject["photo_large_url"]).to eq resource.photo.url(:large)
        expect(subject["photo_large_url"]).to_not be_nil
      end

      it "has a 'state'" do
        expect(subject["state"]).to eq resource.state
        expect(subject["state"]).to_not be_nil
      end
    end
  end
end
