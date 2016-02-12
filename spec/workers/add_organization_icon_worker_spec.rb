require "rails_helper"

describe AddOrganizationIconWorker do
  context "when the organization has 'base64_icon_data'" do
    before do
      file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", "r")
      base64_image = Base64.encode64(open(file, &:read))
      @organization = create(:organization, base64_icon_data: base64_image)
    end

    it "sets 'icon', then unsets 'base64_icon_data'" do
      AddOrganizationIconWorker.new.perform(@organization.id)

      @organization.reload
      expect(@organization.icon.to_s).not_to eq "/icons/original/missing.png"
      expect(@organization.icon.to_s).not_to be_nil
      expect(@organization.base64_icon_data).to be_nil
    end

    it "decodes the image using the Base64ImageDecoder" do
      expect(Base64ImageDecoder).to receive(:decode)

      AddOrganizationIconWorker.new.perform(@organization.id)
    end
  end

  context "when the organization does not have 'base64_icon_data'" do
    before do
      @organization = create(:organization)
    end

    it "doesn't touch icon" do
      AddOrganizationIconWorker.new.perform(@organization.id)
      @organization.reload
      expect(@organization.icon.to_s).to eq "/icons/original/missing.png"
    end
  end
end
