require "rails_helper"

describe "EmberIndex API" do
  context "GET /(*path)" do
    before do
    end

    context "when not found" do
      before do
        allow_any_instance_of(Redis).to receive(:get).and_return nil
      end

      it "renders 'INDEX NOT FOUND'" do
        get "#{host}"
        expect(last_response.status).to eq 200
        expect(last_response.body).to eq "INDEX NOT FOUND"
      end
    end

    context "when in development" do
      before do
        allow(Rails.env).to receive(:development?).and_return true
      end

      it "fetches 'code-corps-ember:index:__development__' from redis" do
        expect_any_instance_of(Redis).to receive(:get).with("code-corps-ember:index:__development__")
        get "#{host}"
      end

      it "renders the fetched index" do
        allow_any_instance_of(Redis).to receive(:get).with("code-corps-ember:index:__development__").and_return "HELLO DEV"
        get "#{host}"
        expect(last_response.status).to eq 200
        expect(last_response.body).to eq "HELLO DEV"
      end
    end

    context "when fetching revision" do
      before do
        @revision = "abcd123"
      end

      it "fetches 'code-corps-ember:index:{revision}' from redis" do
        expect_any_instance_of(Redis).to receive(:get).with("code-corps-ember:index:#{@revision}")
        get "#{host}", { revision: @revision }
      end

      it "renders the fetched index" do
        allow_any_instance_of(Redis).to receive(:get).with("code-corps-ember:index:#{@revision}").and_return "HELLO REVISION"
        get "#{host}", { revision: @revision }

        expect(last_response.status).to eq 200
        expect(last_response.body).to eq "HELLO REVISION"
      end

    end

    context "when fetching latest" do
      before do
        @current_revision = "123abcd"
        allow_any_instance_of(Redis).to receive(:get).with("code-corps-ember:index:current").and_return(@current_revision)
      end

      it "fetches 'code-corps-ember:index:current' from redis" do
        expect_any_instance_of(Redis).to receive(:get).with("code-corps-ember:index:#{@current_revision}")
        get "#{host}"
      end

      it "renders the fetched index" do
        allow_any_instance_of(Redis).to receive(:get).with("code-corps-ember:index:#{@current_revision}").and_return "HELLO CURRENT"
        get "#{host}"

        expect(last_response.status).to eq 200
        expect(last_response.body).to eq "HELLO CURRENT"
      end
    end
  end
end
