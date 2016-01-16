require 'rails_helper'

describe 'SlugValidator' do
  context 'when the record is a User' do
    context 'when the username is valid' do
      it 'returns nil' do
        user = User.new(username: "joshsmith")
        expect(SlugValidator.new({attributes: :username}).validate_each(user, :username, user.username)).to be_nil
      end
    end

    context 'when the username is invalid' do

      context 'due to preceding dashes' do
        it 'returns the error text' do
          user = User.new(username: "-joshsmith")
          expect(SlugValidator.new({attributes: :username}).validate_each(user, :username, user.username)).to eq "may only contain alphanumeric characters, underscores, or single hyphens, and cannot begin or end with a hyphen or underscore"
        end
      end
    end
  end

  context 'when the record is a comment' do
    it 'returns nil' do
      comment = Comment.new
      expect(SlugValidator.new({attributes: :slug}).validate_each(comment, :slug, "slug")).to be_nil
    end
  end

  context "when the record is an Organization" do
    context "when the slug is valid" do
      it 'returns nil' do
        organization = Organization.new(slug: "coderly")
        expect(SlugValidator.new({attributes: :slug}).validate_each(organization, :slug, organization.slug)).to be_nil
      end
    end

    context "when the slug is invalid" do
      it 'returns the error text' do
        organization = Organization.new(slug: "-coderly")
        expect(SlugValidator.new({attributes: :slug}).validate_each(organization, :slug, organization.slug)).to eq "may only contain alphanumeric characters, underscores, or single hyphens, and cannot begin or end with a hyphen or underscore"
      end
    end
  end

  context "when the record is a SluggedRoute" do
    context "when the slug is valid" do
      it 'returns nil' do
        route = SluggedRoute.new(slug: "coderly")
        expect(SlugValidator.new({attributes: :slug}).validate_each(route, :slug, route.slug)).to be_nil
      end
    end

    context "when the slug is invalid" do
      it 'returns the error text' do
        route = SluggedRoute.new(slug: "-coderly")
        expect(SlugValidator.new({attributes: :slug}).validate_each(route, :slug, route.slug)).to eq "may only contain alphanumeric characters, underscores, or single hyphens, and cannot begin or end with a hyphen or underscore"
      end
    end
  end
end
