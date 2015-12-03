module CodeCorps
  module Scenario
    class SaveUser
      def initialize(user)
        @user = user
      end

      def call
        ActiveRecord::Base.transaction do
          @user.save!

          # Attempt to create the slug route
          SlugRoute.find_or_create_by!(owner: @user, slug: @user.username).tap do |r|
            r.slug = @user.username
            r.save!
          end

          @user
        end
      end
    end
  end
end