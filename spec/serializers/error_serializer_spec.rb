require "rails_helper"

describe ErrorSerializer do
  describe  ".serialize" do

    it "can serialize Doorkeeper::OAuth::InvalidTokenResponse" do
      error = Doorkeeper::OAuth::InvalidTokenResponse.new
      result = ErrorSerializer.serialize(error)

      expect(result[:errors]).not_to be_nil
      expect(result[:errors].length).to eq 1

      error = result[:errors].first
      expect(error[:id]).to eq "NOT_AUTHORIZED"
      expect(error[:title]).to eq "Not authorized"
      expect(error[:detail]).to eq "The access token is invalid"
      expect(error[:status]).to eq 401
    end

    it "can serialize Doorkeeper::OAuth::ErrorResponse" do
      error = Doorkeeper::OAuth::ErrorResponse.new name: "invalid_grant"
      result = ErrorSerializer.serialize(error)

      expect(result[:errors]).not_to be_nil
      expect(result[:errors].length).to eq 1

      error = result[:errors].first
      expect(error[:id]).to eq "INVALID_GRANT"
      expect(error[:title]).to eq "Invalid grant"
      expect(error[:detail]).to eq "The provided authorization grant is invalid, expired, revoked, does not match the redirection URI used in the authorization request, or was issued to another client."
      expect(error[:status]).to eq 401
    end

    it "can serialize Pundit::NotAuthorizedError" do
      error = Pundit::NotAuthorizedError.new(record: User.new)
      result = ErrorSerializer.serialize(error)

      expect(result[:errors]).not_to be_nil
      expect(result[:errors].length).to eq 1

      error = result[:errors].first
      expect(error[:id]).to eq "ACCESS_DENIED"
      expect(error[:title]).to eq "Access denied"
      expect(error[:detail]).to eq "You are not authorized to perform this action on users."
      expect(error[:status]).to eq 401
    end

    it "can serialize ActionController::ParameterMissing" do
      error = ActionController::ParameterMissing.new(:user_id)
      result = ErrorSerializer.serialize(error)

      expect(result[:errors]).not_to be_nil
      expect(result[:errors].length).to eq 1

      error = result[:errors].first
      expect(error[:id]).to eq "PARAMETER_MISSING"
      expect(error[:title]).to eq "User is missing"
      expect(error[:detail]).to eq "You must specify a User."
      expect(error[:status]).to eq 400
    end

    it "can serialize ActionController::RoutingError" do
      error_instance = ActionController::RoutingError.new("No route matches test route")
      result = ErrorSerializer.serialize(error_instance)

      expect(result[:errors]).not_to be_nil
      expect(result[:errors].length).to eq 1

      error = result[:errors].first
      expect(error[:id]).to eq "ROUTE_NOT_FOUND"
      expect(error[:title]).to eq "Route not found"
      expect(error[:detail]).to eq error_instance.message
      expect(error[:status]).to eq 404
    end


    it "can serialize Koala::Facebook::AuthenticationError" do
      facebook_authentication_error = Koala::Facebook::AuthenticationError.new(400, nil, { "message" => "A message" })
      result = ErrorSerializer.serialize(facebook_authentication_error)

      expect(result[:errors]).not_to be_nil
      expect(result[:errors].length).to eq 1

      error = result[:errors].first
      expect(error[:id]).to eq "FACEBOOK_AUTHENTICATION_ERROR"
      expect(error[:title]).to eq "Facebook authentication error"
      expect(error[:detail]).to eq "A message"
      expect(error[:status]).to eq 400
    end

    it "can serialize ActiveRecord::RecordNotFound error" do
      record_not_found_error = ActiveRecord::RecordNotFound.new("A message")
      result = ErrorSerializer.serialize(record_not_found_error)

      expect(result[:errors]).not_to be_nil
      expect(result[:errors].length).to eq 1

      error = result[:errors].first
      expect(error[:id]).to eq "RECORD_NOT_FOUND"
      expect(error[:title]).to eq "Record not found"
      expect(error[:detail]).to eq "A message"
      expect(error[:status]).to eq 404
    end
  end
end
