require 'oauth2'

module ApiHelpers
  def authenticate(email:, password:)
    application = create(:oauth_application)
    
    client = OAuth2::Client.new(application.uid, application.secret) do |b|
      b.request :url_encoded
      b.adapter :rack, Rails.application
    end
    access_token = client.password.get_token(email, password)
    access_token.token
  end
end
