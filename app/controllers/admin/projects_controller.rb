class Admin::ProjectsController < Admin::BaseController
  before_action :set_project, only: [ :show, :edit, :update, :destroy ]

  def index
    @projects = Project.includes(:tags).order(created_at: :desc).page(params[:page]).per(20)
  end

  def show
    # Project is set by before_action
  end

  def new
    @project = Project.new
    @tags = Tag.all
  end

  def create
    @project = Project.new(project_params)
    @tags = Tag.all

    if @project.save
      update_project_tags
      redirect_to admin_project_path(@project), notice: "Project was successfully created."
    else
      render :new
    end
  end

  def edit
    @tags = Tag.all
  end

  def update
    if @project.update(project_params)
      update_project_tags
      redirect_to admin_project_path(@project), notice: "Project was successfully updated."
    else
      @tags = Tag.all
      render :edit
    end
  end

  def destroy
    @project.destroy
    redirect_to admin_projects_path, notice: "Project was successfully deleted."
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:title, :description, :slug, :github_url, :demo_url, :published, :source, images: [])
  end

  def update_project_tags
    return unless params[:project][:tag_ids].present?

    tag_ids = params[:project][:tag_ids].reject(&:blank?)
    @project.tag_ids = tag_ids
  end
end
