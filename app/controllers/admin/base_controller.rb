class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin

  layout "admin"

  private

  def ensure_admin
    # For now, any authenticated user is admin
    # In production, you might want to add a role system
    redirect_to root_path unless user_signed_in?
  end
end
