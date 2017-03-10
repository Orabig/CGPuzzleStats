class ResultRefreshJob < ApplicationJob
  queue_as :default

  def perform(*player)
	begin
		Rails.logger.debug('-- Job start --')
		importer = ImportLiveData.new
		importer.refresh_player player.first
		Rails.logger.debug('-- Job end --')
	rescue => e
		Rails.logger.debug("uncaught exception : #{e}")
		Rails.logger.debug(e.backtrace.first(10).map {|l| "  #{l}\n"}.join)
		raise
	end
  end
end
