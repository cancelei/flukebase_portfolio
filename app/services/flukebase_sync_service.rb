class FlukebaseSyncService
  def self.call
    new.call
  end

  def initialize
    @api_url = SiteSetting.get("flukebase_api_url") || "https://flukebase.me/api/v1/"
    @api_key = SiteSetting.get("flukebase_api_key")
  end

  def call
    return { success: false, error: "Flukebase integration is disabled" } unless SiteSetting.get("flukebase_integration_enabled")
    return { success: false, error: "Flukebase API key is not configured" } unless @api_key.present?

    begin
      projects_data = fetch_projects
      if projects_data.present?
        synced_count = sync_projects(projects_data)
        { success: true, synced_count: synced_count }
      else
        { success: false, error: "No projects data received from Flukebase API" }
      end
    rescue => e
      Rails.logger.error "Flukebase sync error: #{e.message}"
      { success: false, error: e.message }
    end
  end

  private

  def fetch_projects
    require "faraday"

    conn = Faraday.new(url: @api_url) do |faraday|
      faraday.request :url_encoded
      faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end

    # Get admin user ID (assuming first user is admin)
    admin_user = User.first
    return unless admin_user

    response = conn.get("projects") do |req|
      req.headers["Authorization"] = "Bearer #{@api_key}"
      req.params["user_id"] = admin_user.id
    end

    if response.success?
      JSON.parse(response.body, symbolize_names: true)
    else
      Rails.logger.error "Flukebase API error: #{response.status} - #{response.body}"
      nil
    end
  end

  def sync_projects(projects_data)
    return 0 unless projects_data.is_a?(Array)

    synced_count = 0
    projects_data.each do |project_json|
      if sync_project(project_json)
        synced_count += 1
      end
    end
    synced_count
  end

  def sync_project(project_json)
    # Check if project already exists (by title or external ID)
    existing_project = Project.find_by(
      title: project_json[:title],
      source: "flukebase"
    )

    begin
      if existing_project
        update_existing_project(existing_project, project_json)
      else
        create_new_project(project_json)
      end
      true
    rescue => e
      Rails.logger.error "Failed to sync project '#{project_json[:title]}': #{e.message}"
      false
    end
  end

  def create_new_project(project_json)
    project = Project.create!(
      title: project_json[:title],
      description: project_json[:description],
      github_url: project_json[:github_url],
      demo_url: project_json[:demo_url],
      published: false, # Keep unpublished by default
      source: "flukebase"
    )

    # Sync tags
    sync_project_tags(project, project_json[:tags]) if project_json[:tags].present?

    Rails.logger.info "Created project from Flukebase: #{project.title}"
    project
  end

  def update_existing_project(project, project_json)
    project.update!(
      description: project_json[:description],
      github_url: project_json[:github_url],
      demo_url: project_json[:demo_url]
    )

    # Sync tags
    sync_project_tags(project, project_json[:tags]) if project_json[:tags].present?

    Rails.logger.info "Updated project from Flukebase: #{project.title}"
    project
  end

  def sync_project_tags(project, tags_data)
    return unless tags_data.is_a?(Array)

    tag_names = tags_data.map { |tag| tag.is_a?(Hash) ? tag[:name] : tag.to_s }.compact
    tags = tag_names.map { |name| Tag.find_or_create_by(name: name) }

    project.tags = tags
  end
end
