require "rails_helper"

describe "Skills API" do
  context "GET /skills" do
    context "when getting all" do
      before do
        @skills = create_list(:skill, 10)
        get "#{host}/skills"
      end

      it "responds with a 200" do
        expect(last_response.status).to eq 200
      end

      it "returns a list of skills, serialized using SkillSerializer, with skill includes" do
        expect(json).to serialize_collection(@skills).
          with(SkillSerializer)
      end
    end

    context "when searching" do
      before do
        create(:skill, title: "Perl")
        create(:skill, title: "Python")
        create(:skill, title: "PostgreSQL")
        create(:skill, title: "PHP")
        create(:skill, title: "Play")
        create(:skill, title: "Meteor")

        @skills = Skill.take(5)

        query = "pe"
        allow(Skill).to receive(:search).with(query) { Skill.all }
        get "#{host}/skills", query: query
      end

      it "responds with a 200" do
        expect(last_response.status).to eq 200
      end

      it "returns a list of skills, serialized using SkillSerializer, with skill includes" do
        expect(json).to serialize_collection(@skills).
          with(SkillSerializer)
      end
    end
  end

  context "POST /skills" do
    context "when unauthenticated" do
      it "responds with a 401 not authorized" do
        post "#{host}/skills", data: { type: "skills" }
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:user) { create :user, password: "password" }
      let(:token) { authenticate email: user.email, password: "password" }

      let(:params) do
        {
          data: {
            type: "skills",
            attributes: {
              title: "JavaScript"
            }
          }
        }
      end

      def make_request(params)
        authenticated_post "/skills", params, token
      end

      context "as a regular user" do
        it "responds with a 401 access denied" do
          make_request(params)
          expect(last_response.status).to eq 401
          expect(json).to be_a_valid_json_api_error.with_id "ACCESS_DENIED"
        end
      end

      context "as an admin user" do
        let(:user) { create :user, password: "password", admin: true }
        let(:token) { authenticate email: user.email, password: "password" }

        context "with valid params" do
          it "works" do
            make_request(params)
            expect(last_response.status).to eq 200
            expect(json).to serialize_object(Skill.last).
              with(SkillSerializer)
          end
        end

        context "when the attributes are invalid" do
          let(:invalid_attributes) do
            {
              data: {
                attributes: {
                  title: nil
                }
              }
            }
          end

          it "responds with a 422 validation error" do
            authenticated_post "/skills", invalid_attributes, token
            expect(last_response.status).to eq 422
            expect(json).to be_a_valid_json_api_validation_error
          end
        end
      end
    end
  end
end
