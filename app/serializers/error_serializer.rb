class ErrorSerializer
  def self.serialize(error)
    error_hash = serialize_doorkeeper_oauth_invalid_token_response(error) if error.class == Doorkeeper::OAuth::InvalidTokenResponse
    error_hash = serialize_doorkeeper_oauth_error_response(error) if error.class == Doorkeeper::OAuth::ErrorResponse
    error_hash = serialize_validation_errors(error) if error.class == ActiveModel::Errors
    error_hash = serialize_pundit_not_authorized_error(error) if error.class == Pundit::NotAuthorizedError
    error_hash = serialize_parameter_missing(error) if error.class == ActionController::ParameterMissing
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

    def self.serialize_parameter_missing(error)
      subject_name = error.param.to_s.humanize.capitalize
      return {
        id: "PARAMETER_MISSING",
        title: "#{subject_name} is missing",
        detail: "You must specify a #{subject_name}.",
        status: 400
      }
    end
end
