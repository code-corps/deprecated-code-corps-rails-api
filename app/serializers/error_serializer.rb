class ErrorSerializer
  def self.serialize(error)
    { errors: [serialize_error(error)] }
  end

  private

    def self.serialize_error(error)
      return serialize_doorkeeper_oauth_invalid_token_response(error) if error.class == Doorkeeper::OAuth::InvalidTokenResponse
      return serialize_doorkeeper_oauth_error_response(error) if error.class == Doorkeeper::OAuth::ErrorResponse
    end   

    def self.serialize_doorkeeper_oauth_invalid_token_response(error)
      return {
        id: "NOT_AUTHORIZED",
        title: "Not authorized",
        detail: error.description,
        status: 401
      }
    end

    def self.serialize_doorkeeper_oauth_error_response(error)
      return {
        id: "INVALID_GRANT",
        title: "Invalid grant",
        detail: error.description,
        status: 401
      }
    end
end