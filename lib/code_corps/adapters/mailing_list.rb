module CodeCorps
  module Adapters
    class MailingList
      def initialize(user)
        @user = user
      end

      def subscribe
        begin
          response = subscribe_with_gibbon
          return response["status"] == "subscribed"
        rescue Gibbon::MailChimpError
          return false
        end
      end

      private

        def gibbon
          @gibbon ||= Gibbon::Request.new # Uses ENV["MAILCHIMP_API_KEY"] by default
        end

        def subscribe_with_gibbon
          gibbon.
            lists(list_id).
            members(lower_case_md5_hashed_email_address).
            upsert(
              body: {
                email_address: @user.email,
                status: "subscribed",
                merge_fields: merge_fields
              }
            )
        end

        def merge_fields
          fields = {}
          fields.merge(FNAME: @user.first_name) if @user.first_name.present?
          fields.merge(LNAME: @user.last_name) if @user.last_name.present?
          fields
        end

        def list_id
          @list_id ||= ENV["MAILCHIMP_LIST_ID"]
        end

        def lower_case_md5_hashed_email_address
          @lower_case_md5_hashed_email_address ||= Digest::MD5.hexdigest(@user.email.downcase)
        end
    end
  end
end
