# == Schema Information
#
# Table name: users
#
#  id                    :integer          not null, primary key
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  email                 :string           not null
#  encrypted_password    :string(128)      not null
#  confirmation_token    :string(128)
#  remember_token        :string(128)      not null
#  username              :string
#  admin                 :boolean          default(FALSE), not null
#  website               :text
#  twitter               :string
#  biography             :text
#  facebook_id           :string
#  facebook_access_token :string
#  base64_photo_data     :string
#  photo_file_name       :string
#  photo_content_type    :string
#  photo_file_size       :integer
#  photo_updated_at      :datetime
#  name                  :text
#  aasm_state            :string           default("signed_up"), not null
#  theme                 :string           default("light")
#

require "rails_helper"

describe UserSerializer, type: :serializer do
  context "individual resource representation" do
    let(:resource) do
      user = create(:user,
                    email: "user@mail.com",
                    name: "Josh Smith",
                    username: "joshsmith",
                    website: "example.com",
                    twitter: "user",
                    biography: "Lorem ipsum",
                    facebook_id: "some_id",
                    facebook_access_token: "some_token")

      create_list(:user_category, 2, user: user)
      create_list(:user_role, 2, user: user)
      create_list(:user_skill, 2, user: user)

      organization = create(:organization)
      create(:organization_membership, organization: organization, member: user)

      user
    end

    let(:serializer) { UserSerializer.new(resource) }
    let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer) }

    context "root" do
      subject do
        JSON.parse(serialization.to_json)["data"]
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

    context "attributes" do
      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has a 'created_at'" do
        expect(subject["created_at"]).to be_the_same_time_as resource.created_at
        expect(subject["created_at"]).to_not be_nil
      end

      it "has a 'username'" do
        expect(subject["username"]).to eq resource.username
        expect(subject["username"]).to_not be_nil
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

      it "has a 'theme'" do
        expect(subject["theme"]).to eq resource.theme
        expect(subject["theme"]).to_not be_nil
      end

      context "when not the current user" do
        it "does not expose 'email'" do
          expect(subject["email"]).to be_nil
        end

        it "does not expose 'facebook_id'" do
          expect(subject["facebook_id"]).to be_nil
        end

        it "does not expose 'facebook_access_token'" do
          expect(subject["facebook_access_token"]).to be_nil
        end
      end

      context "when is the current user" do
        before do
          serializer.scope = resource
        end

        it "has an 'email'" do
          expect(subject["email"]).to eq resource.email
        end

        it "has a 'facebook_id'" do
          expect(subject["facebook_id"]).to eq resource.facebook_id
        end

        it "has a 'facebook_access_token'" do
          expect(subject["facebook_access_token"]).to eq resource.facebook_access_token
        end
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "has a 'categories' relationship" do
        expect(subject["categories"]).not_to be_nil
        expect(subject["categories"]["data"].count).to eq 2
      end

      it "has a 'skills' relationship" do
        expect(subject["skills"]).not_to be_nil
        expect(subject["skills"]["data"].count).to eq 2
      end

      it "has an 'organizations' relationship" do
        expect(subject["organizations"]).not_to be_nil
        expect(subject["organizations"]["data"].count).to eq 1
      end

      it "has an 'organization_memberships' relationship" do
        expect(subject["organization_memberships"]).not_to be_nil
        expect(subject["organization_memberships"]["data"].count).to eq 1
      end

      it "has a 'user_categories' relationship" do
        expect(subject["user_categories"]).not_to be_nil
        expect(subject["user_categories"]["data"].count).to eq 2
      end

      it "has a 'user_skills' relationship" do
        expect(subject["user_skills"]).not_to be_nil
        expect(subject["user_skills"]["data"].count).to eq 2
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

      context "when including categories" do
        let(:serialization) do
          ActiveModel::Serializer::Adapter.create(serializer, include: ["categories"])
        end

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should contain the user's categories" do
          expect(subject).not_to be_nil
          expect(subject.select { |i| i["type"] == "categories" }.length).to eq 2
        end
      end

      context "when including skills" do
        let(:serialization) do
          ActiveModel::Serializer::Adapter.create(serializer, include: ["skills"])
        end

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should contain the user's skills" do
          expect(subject).not_to be_nil
          expect(subject.select { |i| i["type"] == "skills" }.length).to eq 2
        end
      end

      context "when including organizations" do
        let(:serialization) do
          ActiveModel::Serializer::Adapter.create(serializer, include: ["organizations"])
        end

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should contain the user's organizations" do
          expect(subject).not_to be_nil
          expect(subject.select { |i| i["type"] == "organizations" }.length).to eq 1
        end
      end

      context "when including roles" do
        let(:serialization) do
          ActiveModel::Serializer::Adapter.create(serializer, include: ["roles"])
        end

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should contain the user's roles" do
          expect(subject).not_to be_nil
          expect(subject.select { |i| i["type"] == "roles" }.length).to eq 2
        end
      end

      context "when including user_categories" do
        let(:serialization) do
          ActiveModel::Serializer::Adapter.create(serializer, include: ["user_categories"])
        end

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should contain the user's user_categories" do
          expect(subject).not_to be_nil
          expect(subject.select { |i| i["type"] == "user_categories" }.length).to eq 2
        end
      end

      context "when including user_roles" do
        let(:serialization) do
          ActiveModel::Serializer::Adapter.create(serializer, include: ["user_roles"])
        end

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should contain the user's user_roles" do
          expect(subject).not_to be_nil
          expect(subject.select { |i| i["type"] == "user_roles" }.length).to eq 2
        end
      end

      context "when including user_skills" do
        let(:serialization) do
          ActiveModel::Serializer::Adapter.create(serializer, include: ["user_skills"])
        end

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should contain the user's user_skills" do
          expect(subject).not_to be_nil
          expect(subject.select { |i| i["type"] == "user_skills" }.length).to eq 2
        end
      end
    end
  end
end
