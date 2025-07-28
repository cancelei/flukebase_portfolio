class ProjectsController < ApplicationController
  before_action :set_project, only: [ :show ]

  def index
    @projects = Project.published.includes(:tags)

    # Apply search filter
    @projects = @projects.search(params[:search]) if params[:search].present?

    # Apply tag filter
    @projects = @projects.by_tag(params[:tag]) if params[:tag].present?

    # Pagination
    @projects = @projects.page(params[:page]).per(12)

    # For filter options
    @tags = Tag.joins(:projects).where(projects: { published: true }).distinct
  end

  def show
    # Project is set by before_action
  end

  private

  def set_project
    @project = Project.published.find_by!(slug: params[:id])
  end
end
