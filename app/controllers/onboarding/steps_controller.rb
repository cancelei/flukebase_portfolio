class Onboarding::StepsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_if_completed

  STEPS = %w[welcome admin_setup site_settings features smtp_config domain_setup complete].freeze

  def index
    redirect_to onboarding_step_path("welcome")
  end

  def show
    @step = params[:step]
    @current_step_index = STEPS.index(@step) || 0
    @total_steps = STEPS.length

    case @step
    when "welcome"
      # Welcome step
    when "admin_setup"
      # Admin user is already created via Devise
    when "site_settings"
      @site_name = SiteSetting.get("site_name") || "My Portfolio"
    when "features"
      @blog_enabled = SiteSetting.get("blog_enabled")
      @resume_enabled = SiteSetting.get("resume_enabled")
      @ai_chat_enabled = SiteSetting.get("ai_chat_enabled")
      @flukebase_enabled = SiteSetting.get("flukebase_integration_enabled")
    when "smtp_config"
      @smtp_setting = SmtpSetting.first || SmtpSetting.new
    when "domain_setup"
      @custom_domain = SiteSetting.get("custom_domain")
    when "complete"
      # Final step
    else
      redirect_to onboarding_step_path("welcome")
    end
  end

  def update
    @step = params[:step]

    case @step
    when "site_settings"
      SiteSetting.set("site_name", params[:site_name]) if params[:site_name].present?
      redirect_to onboarding_step_path("features")
    when "features"
      SiteSetting.set("blog_enabled", params[:blog_enabled] == "1", "boolean")
      SiteSetting.set("resume_enabled", params[:resume_enabled] == "1", "boolean")
      SiteSetting.set("ai_chat_enabled", params[:ai_chat_enabled] == "1", "boolean")
      SiteSetting.set("flukebase_integration_enabled", params[:flukebase_enabled] == "1", "boolean")
      redirect_to onboarding_step_path("smtp_config")
    when "smtp_config"
      if params[:skip_smtp] == "1"
        redirect_to onboarding_step_path("domain_setup")
      else
        @smtp_setting = SmtpSetting.first || SmtpSetting.new
        if @smtp_setting.update(smtp_params)
          redirect_to onboarding_step_path("domain_setup")
        else
          render :show
        end
      end
    when "domain_setup"
      SiteSetting.set("custom_domain", params[:custom_domain]) if params[:custom_domain].present?
      redirect_to onboarding_step_path("complete")
    else
      redirect_to onboarding_step_path("welcome")
    end
  end

  def complete
    SiteSetting.set("onboarding_complete", true, "boolean")
    redirect_to admin_dashboard_path, notice: "Welcome! Your portfolio is now set up and ready to use."
  end

  private

  def redirect_if_completed
    if SiteSetting.get("onboarding_complete")
      redirect_to admin_dashboard_path
    end
  end

  def smtp_params
    params.require(:smtp_setting).permit(:address, :port, :domain, :user_name, :password, :tls_enabled)
  end
end
