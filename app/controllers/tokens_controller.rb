class TokensController < Doorkeeper::TokensController
  def create
    user_id = authenticate_with_credentials

  rescue Doorkeeper::Errors::DoorkeeperError,
         Doorkeeper::Errors::InvalidGrantReuse,
         Doorkeeper::OAuth::Error,
         Koala::Facebook::AuthenticationError,
         ActiveRecord::RecordNotFound => e

    Raven.capture_exception e
    render_error e
  end

  private

    def render_error(error)
      error_hash = ErrorSerializer.serialize(error)
      render json: error_hash, status: error_hash[:errors][0][:status]
    end

    def authenticate_with_credentials
      response = strategy.authorize
      if response.class == Doorkeeper::OAuth::TokenResponse
        handle_authentication_successful response
      elsif response.class == Doorkeeper::OAuth::ErrorResponse
        render_error response
      end
    end

    def handle_authentication_successful(response)
      self.headers.merge! response.headers
      self.status = response.status

      user_id = response.try(:token).try(:resource_owner_id)
      body = response.body.merge('user_id' => user_id)
      self.response_body = body.to_json

      return user_id
    end
end
