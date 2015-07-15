require 'rails_helper'

describe "OAuth Applications API" do

  it 'does not show the oauth applications page when unauthed' do
    get "#{host}/oauth/applications"

    expect(last_response.status).to eq 401
  end

end