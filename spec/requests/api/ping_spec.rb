require 'rails_helper'

describe "Ping API" do

  let(:token) { authenticate(email: "josh@coderly.com", password: "password") }

  it 'gets a pong when pinging unauthed' do
    get "#{host}/ping"

    expect(last_response.status).to eq 200
    expect(json.ping).to eq "pong"
  end

  it 'pongs the user email when authed' do
    create(:user, email: "josh@coderly.com", password: "password")

    authenticated_get "ping", nil, token

    expect(last_response.status).to eq 200
    expect(json.ping).to eq "josh@coderly.com"
  end

end