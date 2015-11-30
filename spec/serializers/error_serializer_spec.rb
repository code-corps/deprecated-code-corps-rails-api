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

    it "can serialize CanCan::AccessDenied" do
      error = CanCan::AccessDenied.new(nil, :delete, User.new)
      result = ErrorSerializer.serialize(error)

      expect(result[:errors]).not_to be_nil
      expect(result[:errors].length).to eq 1

      error = result[:errors].first
      expect(error[:id]).to eq "ACCESS_DENIED"
      expect(error[:title]).to eq "Access denied"
      expect(error[:detail]).to eq "You are not authorized to perform deletes on this user."
      expect(error[:status]).to eq 401
    end
  end
end
