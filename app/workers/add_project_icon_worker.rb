require "code_corps/base64_image_decoder"

class AddProjectIconWorker
  include Sidekiq::Worker

  def perform(project_id)
    project = Project.find(project_id)
    return unless project.base64_icon_data
    project.icon = Base64ImageDecoder.new(project.base64_icon_data).decode
    project.base64_icon_data = nil
    project.save
  end
end