require "code_corps/slug_matcher"

class SlugValidator < ActiveModel::Validator

  def validate(record)
    if record.instance_of? User
      validate_username(record)
    end
  end

  private

    def validate_username(record)
      unless valid_slug?(record.username)
        record.errors[:username] = "Username may only contain alphanumeric characters, underscores, or single hyphens, and cannot begin or end with a hyphen or underscore"
      end
    end

    def valid_slug?(slug)
      slug_matcher.match?(slug)
    end

    def slug_matcher
      @slug_matcher ||= SlugMatcher.new
    end
end