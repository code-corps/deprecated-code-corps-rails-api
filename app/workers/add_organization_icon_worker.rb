class AddOrganizationIconWorker
  include Sidekiq::Worker

  def perform(organization_id)
    organization = Organization.find(organization_id)
    return unless organization.base64_icon_data
    organization.decode_image_data
    organization.base64_icon_data = nil
    organization.save
  end
end
