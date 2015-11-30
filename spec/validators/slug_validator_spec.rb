require 'rails_helper'

describe 'SlugValidator' do
  context 'when the record is a user' do
    context 'when the username is valid' do
      it 'returns nil' do
        user = User.new(username: "joshsmith")
        expect(SlugValidator.new.validate(user)).to be_nil
      end
    end

    context 'when the username is invalid' do

      context 'due to preceding dashes' do
        it 'returns the error text' do
          user = User.new(username: "-joshsmith")
          expect(SlugValidator.new.validate(user)).to eq "may only contain alphanumeric characters, underscores, or single hyphens, and cannot begin or end with a hyphen or underscore"
        end
      end
    end
  end

  context 'when the record is a comment' do
    it 'returns nil' do
      comment = Comment.new
      expect(SlugValidator.new.validate(comment)).to be_nil
    end
  end
end