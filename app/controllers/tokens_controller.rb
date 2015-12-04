class TokensController < Doorkeeper::TokensController
  def create

    if signing_in_with_facebook?
      user_id = authenticate_with_facebook
    else
      user_id = authenticate_with_credentials
    end

  rescue Doorkeeper::Errors::DoorkeeperError,
         Doorkeeper::Errors::InvalidGrantReuse,
         Doorkeeper::OAuth::Error,
         Koala::Facebook::AuthenticationError,
         ActiveRecord::RecordNotFound => e

    render_error e
  end

  private

    def signing_in_with_facebook?
      params[:username] == "facebook"
    end

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

    def authenticate_with_facebook
      user_id = get_user_id_from_facebook_information
      token_data = generate_token_data(user_id)
      render json: token_data.to_json, status: :ok

      return user_id
    end

      def get_user_id_from_facebook_information
        facebook_access_token = params[:password]
        graph = Koala::Facebook::API.new(facebook_access_token, ENV["FACEBOOK_APP_SECRET"])
        facebook_user = graph.get_object("me", { fields: ['email', 'first_name', 'last_name']})

        User.find_by!(facebook_id: facebook_user["id"]).id
      end

      def generate_token_data(user_id)
        doorkeeper_access_token = Doorkeeper::AccessToken.create!({
          application_id: nil,
          resource_owner_id: user_id,
          expires_in: 7200})

        return {
          access_token: doorkeeper_access_token.token,
          token_type: 'bearer',
          expires_in: doorkeeper_access_token.expires_in,
          user_id: user_id.to_s
        }
      end
end
