class PerformImportWorker
  include Sidekiq::Worker

  def perform(import_id)
    import = Import.find(import_id)

    CSV.parse(Paperclip.io_adapters.for(import.file).read, headers: true).each do |line|
      next unless ["Categorize", "Import - QA", "Import"].include?(line["Status"])

      # Add skill if needed and update title.
      skill = Skill.find_or_create_by(original_row: line["Original Row"])

      if skill.update(title: line["Skill"])
        process_roles(skill, line)
        import.processed!
      else
        process_failure(import, skill, line)
        import.failed!
      end
    end
  end

  private

    def process_roles(skill, csv_row)
      (1..6).each do |col|
        next if csv_row[col].blank?
        role = Role.find_by(name: csv_row["Cat #{col}"])
        role_skill = skill.role_skills.find_or_create_by(role: role)
        role_skill.update(cat: "cat#{col}".intern)
      end
    end

    def process_failure(import, skill, csv_row)
      failure = ImportSkillFailure.new(
        import: import,
        data: csv_row.to_hash.with_indifferent_access,
        issues: skill.errors.full_messages)

      # could be we can't even create a skill due to slug being taken
      failure.skill = skill if skill.persisted?
      failure.save!
    end
end
