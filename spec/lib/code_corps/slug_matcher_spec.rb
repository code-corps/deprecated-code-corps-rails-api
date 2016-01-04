require "code_corps/slug_matcher"

module CodeCorps
  describe SlugMatcher do
    let(:slug_matcher) { SlugMatcher.new }

    describe "#match" do
      context 'matches slugs' do
        it 'with only letters' do
          expect(slug_matcher.match?('slug')).to eq true
        end

        it 'with preceding underscores' do
          expect(slug_matcher.match?('_slug')).to eq true
        end

        it 'with suffixed underscores' do
          expect(slug_matcher.match?('slug_')).to eq true
        end

        it 'with preceding numbers' do
          expect(slug_matcher.match?('123slug')).to eq true
        end

        it 'with suffixed numbers' do
          expect(slug_matcher.match?('slug123')).to eq true
        end

        it 'with multiple dashes' do
          expect(slug_matcher.match?('slug-slug-slug')).to eq true
        end

        it 'with multiple underscores' do
          expect(slug_matcher.match?('slug_slug_slug')).to eq true
        end

        it 'with multiple consecutive underscores' do
          expect(slug_matcher.match?('slug___slug')).to eq true
        end

        it 'with one character' do
          expect(slug_matcher.match?('s')).to eq true
        end
      end

      context 'does not match slugs' do
        it 'with preceding symbols' do
          expect(slug_matcher.match?('@slug')).to eq false
        end

        it 'with preceding dashes' do
          expect(slug_matcher.match?('-slug')).to eq false
        end

        it 'with suffixed dashes' do
          expect(slug_matcher.match?('slug-')).to eq false
        end

        it 'with multiple consecutive dashes' do
          expect(slug_matcher.match?('slug---slug')).to eq false
        end

        it 'with single slashes' do
          expect(slug_matcher.match?('slug/slug')).to eq false
        end

        it 'with multiple slashes' do
          expect(slug_matcher.match?('slug/slug/slug')).to eq false
        end

        it 'with multiple consecutive slashes' do
          expect(slug_matcher.match?('slug///slug')).to eq false
        end
      end
    end
  end
end