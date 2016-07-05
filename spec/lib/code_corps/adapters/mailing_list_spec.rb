require "rails_helper"
require "code_corps/adapters/mailing_list"

module CodeCorps
  module Adapters
    describe MailingList do
      let(:list_id) { ENV["MAILCHIMP_LIST_ID"] }
      let(:user) { create(:user) }
      let(:member_id) { Digest::MD5.hexdigest(user.email) }
      let(:request_body) do
        {
          email_address: user.email,
          status: "subscribed",
          merge_fields: { FNAME: user.first_name, LNAME: user.last_name }
        }
      end

      before do
        ENV["MAILCHIMP_API_KEY"] = "1234-us12"
      end

      after do
        ENV["MAILCHIMP_API_KEY"] = nil
      end

      describe "#subscribe" do
        context "when subscription succeeds" do
          it "returns true" do
            stub_request(
              :put,
              "https://us12.api.mailchimp.com/3.0/lists/#{list_id}/members/#{member_id}"
            ).
              to_return(body: "{ \"status\": \"subscribed\" }")

            result = MailingList.new(user).subscribe
            expect(result).to eq true
          end
        end

        context "when subscription fails" do
          it "returns false" do
            stub_request(
              :put,
              "https://us12.api.mailchimp.com/3.0/lists/#{list_id}/members/#{member_id}"
            ).
              to_return(body: "{ \"status\": \"unsubscribed\" }")

            result = MailingList.new(user).subscribe
            expect(result).to eq false
          end
        end

        context "when an error occurs" do
          it "returns false" do
            stub_request(
              :put,
              "https://us12.api.mailchimp.com/3.0/lists/#{list_id}/members/#{member_id}"
            ).
              to_return(status: 500)

            result = MailingList.new(user).subscribe
            expect(result).to eq false
          end
        end
      end
    end
  end
end
