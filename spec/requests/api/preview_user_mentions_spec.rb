require "rails_helper"

describe "PreviewUserMentions API" do
  context "GET /preview_user_mentions/" do
    def make_request_for_preview(preview)
      get "#{host}/preview_user_mentions/", preview_id: preview.id
    end

    let(:preview_a) { create(:preview) }
    let(:preview_b) { create(:preview) }

    before do
      create_list(:preview_user_mention, 4, preview: preview_a)
      create_list(:preview_user_mention, 1, preview: preview_b)
    end

    it "fetches mentions of specified status for specified post" do
      make_request_for_preview(preview_a)
      expect(last_response.status).to eq 200
      expect(json).
        to serialize_collection(preview_a.preview_user_mentions.all).
        with(PreviewUserMentionSerializer)

      make_request_for_preview(preview_b)
      expect(last_response.status).to eq 200
      expect(json).
        to serialize_collection(preview_b.preview_user_mentions.all).
        with(PreviewUserMentionSerializer)
    end
  end
end
