class PerformImportWorker
  include Sidekiq::Worker

  def perform(import_id)
    import = Import.find(import_id)

    CSV.parse(Paperclip.io_adapters.for(import.file).read, headers: true).each do |line|
      line = line.split(',')
      next if line.first.blank?

      # Add skill if needed and update title.
      skill = Skill.find_or_create_by(original_row: line.third)
      skill.update(title: line.fifth)

      # Add or update roles.
      (5..10).each do |col|
        next if line[col].blank?
        role = Role.find_by(name: line[col])
        skill_role = skill.roles.find_or_create_by(role: role)
        skill_role.update(col: "cat#{col - 4}".intern)
      end
    end

    import.processed!
  end
  
end
