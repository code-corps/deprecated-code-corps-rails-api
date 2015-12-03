module CodeCorps
  module Scenario
    class SaveOrganization
      def initialize(organization)
        @organization = organization
      end

      def call
        ActiveRecord::Base.transaction do
          @organization.save!

          # Attempt to create the slug route
          SlugRoute.find_or_create_by!(owner: @organization, slug: @organization.slug).tap do |r|
            r.slug = @organization.slug
            r.save!
          end

          @organization
        end
      end
    end
  end
end