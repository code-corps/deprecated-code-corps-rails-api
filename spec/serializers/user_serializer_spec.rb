require "rails_helper"

describe UserSerializer, :type => :serializer do

  context "individual resource representation" do
    let(:resource) {
      user = create(:user,
        email: "user@mail.com",
        username: "user",
        website: "example.com",
        twitter: "@user",
        biography: "Lorem ipsum")
      create_list(:user_skill, 10, user: user)
      user
    }

    let(:serializer) { UserSerializer.new(resource) }
    let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer) }

    context "root" do
      subject do
        JSON.parse(serialization.to_json)['data']
      end

      it "has an attributes object" do
        expect(subject["attributes"]).not_to be_nil
      end

      it "has a relationships object" do
        expect(subject["relationships"]).not_to be_nil
      end

      it "has an id" do
        expect(subject["id"]).to eq resource.id.to_s
      end

      it "has a type set to `users`" do
        expect(subject["type"]).to eq "users"
      end
    end

    context 'attributes' do
      subject do
        JSON.parse(serialization.to_json)['data']['attributes']
      end

      it "has an 'email'" do
        expect(subject["email"]).to eq resource.email
      end

      it "has a 'username'" do
        expect(subject["username"]).to eq resource.username
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
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "has a 'skills' relationship" do
        expect(subject["skills"]).not_to be_nil
        expect(subject["skills"]["data"].count).to eq 10
      end
    end

    context "included" do
      context "when not including anything" do
        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should be empty" do
          expect(subject).to be_nil
        end
      end

      context "when including skills" do
        let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer, include: ["skills"]) }

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should contain the user's skills" do
          expect(subject).not_to be_nil
          expect(subject.select{ |i| i["type"] == "skills"}.length).to eq 10
        end
      end
    end
  end
end
