require "code_corps/slug_matcher"

class SlugValidator < ActiveModel::Validator

  def validate(record)
    if record.instance_of? User
      return validate_property(record, :username)
    end

    if record.instance_of? Organization
      return validate_property(record, :slug)
    end

    if record.instance_of? Member
      return validate_property(record, :slug)
    end
  end

  private

    def validate_property(record, property)
      unless valid_slug?(record.send(property))
        record.errors[property] = "may only contain alphanumeric characters, underscores, or single hyphens, and cannot begin or end with a hyphen or underscore"
      end
    end

    def valid_slug?(slug)
      slug_matcher.match?(slug)
    end

    def slug_matcher
      @slug_matcher ||= SlugMatcher.new
    end
end
