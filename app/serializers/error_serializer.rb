class ErrorSerializer
  def self.serialize(error)
    error_hash = serialize_doorkeeper_oauth_invalid_token_response(error) if error.class == Doorkeeper::OAuth::InvalidTokenResponse
    error_hash = serialize_doorkeeper_oauth_error_response(error) if error.class == Doorkeeper::OAuth::ErrorResponse
    error_hash = serialize_validation_errors(error) if error.class == ActiveModel::Errors
    error_hash = serialize_pundit_not_authorized_error(error) if error.class == Pundit::NotAuthorizedError
    error_hash = serialize_action_controller_routing_error(error) if error.class == ActionController::RoutingError
    error_hash = serialize_facebook_authentication_error(error) if error.class == Koala::Facebook::AuthenticationError
    error_hash = serialize_record_not_found_error(error) if error.class == ActiveRecord::RecordNotFound

    { errors: Array.wrap(error_hash) }
  end

  private

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

    def self.serialize_pundit_not_authorized_error(error)
      subject_name = error.record.class.to_s.pluralize.underscore.humanize.downcase
      return {
        id: "ACCESS_DENIED",
        title: "Access denied",
        detail: "You are not authorized to perform this action on #{subject_name}.",
        status: 401
      }
    end

    def self.serialize_validation_errors(errors)
      errors.to_hash(true).map do |k, v|
        v.map do |msg|
          { id: "VALIDATION_ERROR", title: "#{k.capitalize} error", detail: msg, status: 422 }
        end
      end.flatten
    end

    def self.serialize_action_controller_routing_error(error)
      return {
        id: "ROUTE_NOT_FOUND",
        title: "Route not found",
        detail: error.message,
        status: 404
      }
    end

    def self.serialize_facebook_authentication_error(error)
      return {
        id: "FACEBOOK_AUTHENTICATION_ERROR",
        title: "Facebook authentication error",
        detail: error.fb_error_message,
        status: error.http_status
      }
    end

    def self.serialize_record_not_found_error(error)
      return {
        id: "RECORD_NOT_FOUND",
        title: "Record not found",
        detail: error.message,
        status: 404
      }
    end
end
