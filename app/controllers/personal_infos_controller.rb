class PersonalInfosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_personal_info, only: [ :show, :update ]

  def show
    @personal_info = PersonalInfo.current
  end

  def update
    if @personal_info.update(personal_info_params)
      redirect_to cv_path, notice: "Personal information updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_personal_info
    @personal_info = PersonalInfo.current
  end

  def personal_info_params
    params.require(:personal_info).permit(:name, :title, :email, :phone, :location, :website, :linkedin, :twitter, :github, :summary)
  end
end
