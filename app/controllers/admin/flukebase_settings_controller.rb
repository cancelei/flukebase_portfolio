class Admin::FlukebaseSettingsController < Admin::BaseController
  def show
    @flukebase_enabled = SiteSetting.get("flukebase_integration_enabled")
    @api_key = SiteSetting.get("flukebase_api_key")
    @api_url = SiteSetting.get("flukebase_api_url") || "https://flukebase.me/api/v1/"
    @last_sync = SiteSetting.get("flukebase_last_sync")
    @sync_count = SiteSetting.get("flukebase_sync_count") || 0
  end

  def update
    begin
      # Update settings
      SiteSetting.set("flukebase_integration_enabled", params[:flukebase_integration_enabled] == "1")
      SiteSetting.set("flukebase_api_key", params[:flukebase_api_key]) if params[:flukebase_api_key].present?
      SiteSetting.set("flukebase_api_url", params[:flukebase_api_url]) if params[:flukebase_api_url].present?

      redirect_to admin_flukebase_settings_path, notice: "Flukebase settings updated successfully."
    rescue => e
      redirect_to admin_flukebase_settings_path, alert: "Error updating settings: #{e.message}"
    end
  end

  def test_connection
    if SiteSetting.get("flukebase_api_key").blank?
      render json: { success: false, error: "API key is required" }, status: 400
      return
    end

    begin
      # Test the connection by making a simple API call
      require "faraday"

      api_url = SiteSetting.get("flukebase_api_url") || "https://flukebase.me/api/v1/"
      api_key = SiteSetting.get("flukebase_api_key")

      conn = Faraday.new(url: api_url) do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
      end

      response = conn.get("projects") do |req|
        req.headers["Authorization"] = "Bearer #{api_key}"
        req.params["limit"] = 1  # Just test with one project
      end

      if response.success?
        data = JSON.parse(response.body, symbolize_names: true)
        project_count = data.is_a?(Array) ? data.length : 0
        render json: {
          success: true,
          message: "Connection successful! Found #{project_count} project(s).",
          status: response.status
        }
      else
        render json: {
          success: false,
          error: "API returned status #{response.status}: #{response.body}",
          status: response.status
        }
      end
    rescue => e
      render json: { success: false, error: "Connection failed: #{e.message}" }
    end
  end

  def sync_now
    if SiteSetting.get("flukebase_api_key").blank?
      redirect_to admin_flukebase_settings_path, alert: "API key is required for syncing."
      return
    end

    begin
      result = FlukebaseSyncService.call

      if result[:success]
        # Update sync statistics
        SiteSetting.set("flukebase_last_sync", Time.current.iso8601)
        current_count = SiteSetting.get("flukebase_sync_count") || 0
        SiteSetting.set("flukebase_sync_count", current_count + result[:synced_count])

        redirect_to admin_flukebase_settings_path,
                   notice: "Sync completed successfully! #{result[:synced_count]} project(s) synced."
      else
        redirect_to admin_flukebase_settings_path,
                   alert: "Sync failed: #{result[:error]}"
      end
    rescue => e
      redirect_to admin_flukebase_settings_path,
                 alert: "Sync error: #{e.message}"
    end
  end
end
