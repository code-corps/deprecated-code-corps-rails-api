require "code_corps/base64_image_decoder"

class AddOrganizationIconWorker
  include Sidekiq::Worker

  def perform(organization_id)
    organization = Organization.find(organization_id)
    return unless organization.base64_icon_data
    organization.icon = Base64ImageDecoder.decode(organization.base64_icon_data)
    organization.base64_icon_data = nil
    organization.save
  end
end
