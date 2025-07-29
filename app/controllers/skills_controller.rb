class SkillsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_skill, only: [ :show, :update, :destroy ]

  def index
    @skills = Skill.ordered
    @skill = Skill.new
  end

  def create
    @skill = Skill.new(skill_params)

    if @skill.save
      redirect_to cv_path, notice: "Skill added successfully."
    else
      @skills = Skill.ordered
      redirect_to cv_path, alert: @skill.errors.full_messages.join(", ")
    end
  end

  def update
    if @skill.update(skill_params)
      redirect_to cv_path, notice: "Skill updated successfully."
    else
      redirect_to cv_path, alert: @skill.errors.full_messages.join(", ")
    end
  end

  def destroy
    @skill.destroy
    redirect_to cv_path, notice: "Skill deleted successfully."
  end

  private

  def set_skill
    @skill = Skill.find(params[:id])
  end

  def skill_params
    params.require(:skill).permit(:name, :category, :proficiency_level, :position)
  end
end
