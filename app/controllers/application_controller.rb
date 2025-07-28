class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # CSRF protection
  protect_from_forgery with: :exception

  # Pundit authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :check_onboarding_status

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end

  def check_onboarding_status
    return if request.path.starts_with?("/onboarding") || request.path.starts_with?("/users")
    return unless user_signed_in?

    unless SiteSetting.get("onboarding_complete")
      redirect_to onboarding_path
    end
  end
end
