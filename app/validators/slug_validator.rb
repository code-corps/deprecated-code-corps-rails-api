require "code_corps/slug_matcher"

class SlugValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    validate_property(record, attribute, value)
  end

  private

    def validate_property(record, attribute, value)
      unless valid_slug?(value)
        record.errors[attribute] = "may only contain alphanumeric characters, underscores, or single hyphens, and cannot begin or end with a hyphen or underscore"
      end
    end

    def valid_slug?(slug)
      slug_matcher.match?(slug)
    end

    def slug_matcher
      @slug_matcher ||= SlugMatcher.new
    end
end
