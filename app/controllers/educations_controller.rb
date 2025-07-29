class EducationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_education, only: [ :show, :update, :destroy ]

  def index
    @educations = Education.ordered
    @education = Education.new
  end

  def create
    @education = Education.new(education_params)

    if @education.save
      redirect_to cv_path, notice: "Education record added successfully."
    else
      @educations = Education.ordered
      redirect_to cv_path, alert: @education.errors.full_messages.join(", ")
    end
  end

  def update
    if @education.update(education_params)
      redirect_to cv_path, notice: "Education record updated successfully."
    else
      redirect_to cv_path, alert: @education.errors.full_messages.join(", ")
    end
  end

  def destroy
    @education.destroy
    redirect_to cv_path, notice: "Education record deleted successfully."
  end

  private

  def set_education
    @education = Education.find(params[:id])
  end

  def education_params
    params.require(:education).permit(:institution, :degree, :field_of_study, :start_date, :end_date, :current, :gpa, :achievements, :position)
  end
end
