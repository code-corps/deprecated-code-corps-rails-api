class AddProjectIconWorker
  include Sidekiq::Worker

  def perform(project_id)
    project = Project.find(project_id)
    return unless project.base64_icon_data
    project.decode_image_data
    project.base64_icon_data = nil
    project.save
  end
end
