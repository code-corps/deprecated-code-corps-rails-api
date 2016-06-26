class PerformImportWorker
  include Sidekiq::Worker

  def perform(import_id)
    import = Import.find(import_id)
  end
  
end
