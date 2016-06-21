require "rails_helper"
require "code_corps/scenario/generate_preview_mentions"

module CodeCorps
  module Scenario
    describe GeneratePreviewMentions do
      describe "#call" do
        let(:user) { create(:user, username: "joshsmith") }
        let(:preview) { create(:preview) }

        before do
          # need to disable the default after save hook which generates mentions
          allow_any_instance_of(Preview).to receive(:generate_mentions)
        end

        it "creates user mentions from body when publishing" do
          preview.markdown = "Mentioning @#{user.username}"
          preview.save

          GeneratePreviewMentions.new(preview).call

          mention = PreviewUserMention.last
          expect(mention.preview).to eq preview
          expect(mention.user).to eq user
          expect(mention.username).to eq user.username
        end

        it "does not fail when content is nil" do
          preview.markdown = nil
          preview.save
          expect { GeneratePreviewMentions.new(preview).call }.not_to raise_error
        end
      end
    end
  end
end
