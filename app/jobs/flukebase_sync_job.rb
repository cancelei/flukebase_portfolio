class FlukebaseSyncJob < ApplicationJob
  queue_as :default

  def perform
    return unless SiteSetting.get("flukebase_integration_enabled")
    return unless SiteSetting.get("flukebase_api_key").present?

    result = FlukebaseSyncService.call

    if result[:success]
      # Update sync statistics
      SiteSetting.set("flukebase_last_sync", Time.current.iso8601)
      current_count = SiteSetting.get("flukebase_sync_count") || 0
      SiteSetting.set("flukebase_sync_count", current_count + result[:synced_count])

      Rails.logger.info "Flukebase sync completed: #{result[:synced_count]} projects synced"
    else
      Rails.logger.error "Flukebase sync failed: #{result[:error]}"
    end
  end
end
