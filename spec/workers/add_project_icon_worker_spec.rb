require "rails_helper"

describe AddProjectIconWorker do
  context "when the project has 'base64_icon_data'" do
    before do
      file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", "r")
      base64_image = Base64.encode64(open(file, &:read))
      @project = create(:project, base64_icon_data: base64_image)
    end

    it "sets 'icon', then unsets 'base64_icon_data'" do
      AddProjectIconWorker.new.perform(@project.id)

      @project.reload
      expect(@project.icon.to_s).not_to eq "/icons/original/missing.png"
      expect(@project.icon.to_s).not_to be_nil
      expect(@project.base64_icon_data).to be_nil
    end

    it "decodes the image using the Base64ImageDecoder" do
      expect_any_instance_of(Base64ImageDecoder).to receive(:decode)

      AddProjectIconWorker.new.perform(@project.id)
    end
  end

  context "when the project does not have 'base64_icon_data'" do
    before do
      @project = create(:project)
    end

    it "doesn't touch icon" do
      AddProjectIconWorker.new.perform(@project.id)

      @project.reload
      expect(@project.icon.to_s).to eq "/icons/original/missing.png"
    end
  end
end
