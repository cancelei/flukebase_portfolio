class ResumesController < ApplicationController
  def show
    @resume = Resume.first

    if @resume&.file&.attached?
      redirect_to rails_blob_path(@resume.file, disposition: "inline")
    else
      redirect_to root_path, alert: "Resume not available"
    end
  end
end
