class CertificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_certification, only: [ :show, :update, :destroy ]

  def index
    @certifications = Certification.ordered
    @certification = Certification.new
  end

  def create
    @certification = Certification.new(certification_params)

    if @certification.save
      redirect_to cv_path, notice: "Certification added successfully."
    else
      @certifications = Certification.ordered
      redirect_to cv_path, alert: @certification.errors.full_messages.join(", ")
    end
  end

  def update
    if @certification.update(certification_params)
      redirect_to cv_path, notice: "Certification updated successfully."
    else
      redirect_to cv_path, alert: @certification.errors.full_messages.join(", ")
    end
  end

  def destroy
    @certification.destroy
    redirect_to cv_path, notice: "Certification deleted successfully."
  end

  private

  def set_certification
    @certification = Certification.find(params[:id])
  end

  def certification_params
    params.require(:certification).permit(:name, :issuer, :issue_date, :expiry_date, :credential_id, :credential_url, :position)
  end
end
