class PerformImportWorker
  include Sidekiq::Worker

  def perform(import_id)
    import = Import.find(import_id)

    CSV.parse(Paperclip.io_adapters.for(import.file).read, headers: true).each do |line|
      next if line["Status"].blank?

      # Add skill if needed and update title.
      skill = Skill.find_or_create_by(original_row: line["Original Row"])
      skill.update(title: line["Skill"])

      # Add or update roles.
      (1..6).each do |col|
        next if line[col].blank?
        role = Role.find_by(name: line["Cat #{col}"])
        role_skill = skill.role_skills.find_or_create_by(role: role)
        role_skill.update(cat: "cat#{col}".intern)
      end
    end

    import.processed!
  end
end
