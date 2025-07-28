class Admin::SiteSettingsController < Admin::BaseController
  def index
    @site_settings = SiteSetting.all.order(:key)
    @new_setting = SiteSetting.new
  end

  def update
    if params[:site_settings].present?
      params[:site_settings].each do |key, attributes|
        setting = SiteSetting.find_or_initialize_by(key: key)
        setting.update(attributes.permit(:value, :value_type))
      end
      redirect_to admin_site_settings_path, notice: "Settings updated successfully."
    elsif params[:site_setting].present?
      # Create new setting
      @new_setting = SiteSetting.new(site_setting_params)
      if @new_setting.save
        redirect_to admin_site_settings_path, notice: "Setting created successfully."
      else
        @site_settings = SiteSetting.all.order(:key)
        render :index
      end
    else
      redirect_to admin_site_settings_path, alert: "No settings to update."
    end
  end

  private

  def site_setting_params
    params.require(:site_setting).permit(:key, :value, :value_type)
  end
end
