class ErrorSerializer
  def self.serialize(error)
    { errors: [serialize_error(error)] }
  end

  private

    def self.serialize_error(error)
      return serialize_doorkeeper_oauth_invalid_token_response(error) if error.class == Doorkeeper::OAuth::InvalidTokenResponse
      return serialize_doorkeeper_oauth_error_response(error) if error.class == Doorkeeper::OAuth::ErrorResponse
      return serialize_cancan_access_denied(error) if error.class == CanCan::AccessDenied
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

    def self.serialize_cancan_access_denied(error)
      action_name = error.action.to_s.pluralize
      subject_name = error.subject.class.to_s.downcase
      return {
        id: "ACCESS_DENIED",
        title: "Access denied",
        detail: "You are not authorized to perform #{action_name} on this #{subject_name}.",
        status: 401
      }
    end
end
