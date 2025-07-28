class SharedEditingController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_content, only: [ :show, :update ]

  def show
    # This will render the edit form for the specific content
    respond_to do |format|
      format.html { render partial: "shared_editing/edit_form", locals: { content: @content } }
      format.json { render json: { content: @content } }
    end
  end

  def update
    case @content_type
    when "site_setting"
      update_site_setting
    when "cv_entry", "cventry"
      update_cv_entry
    when "project"
      update_project
    when "blog_post", "blogpost"
      update_blog_post
    else
      render json: { error: "Invalid content type: #{@content_type}" }, status: 400
    end
  end

  private

  def set_editable_content
    @content_type = params[:content_type].to_s.downcase
    @content_id = params[:content_id]
    @field = params[:field]

    case @content_type
    when "site_setting"
      @content = SiteSetting.find_by(key: @content_id)
    when "cv_entry", "cventry"  # Handle both cases
      @content = CvEntry.find(@content_id)
    when "project"
      @content = Project.find(@content_id)
    when "blog_post", "blogpost"  # Handle both cases
      @content = BlogPost.find(@content_id)
    else
      render json: { error: "Invalid content type: #{@content_type}" }, status: 400
      return
    end

    unless @content
      render json: { error: "Content not found" }, status: 404
    end
  end

  def update_site_setting
    if @content.update(value: params[:value])
      render json: {
        success: true,
        content: @content.value,
        message: "Site setting updated successfully"
      }
    else
      render json: {
        success: false,
        errors: @content.errors.full_messages
      }, status: 422
    end
  end

  def update_cv_entry
    field_value = case @field
    when "title"
      params[:value]
    when "content"
      params[:value]
    else
      render json: { error: "Invalid field" }, status: 400
      return
    end

    begin
      if @field == "content"
        # Handle ActionText rich content - preserve formatting
        @content.content = field_value
        if @content.save
          render json: {
            success: true,
            content: @content.content.body.to_html,
            message: "CV entry updated successfully"
          }
        else
          render json: {
            success: false,
            errors: @content.errors.full_messages
          }, status: 422
        end
      else
        # Handle regular fields
        if @content.update(@field => field_value)
          render json: {
            success: true,
            content: @content.send(@field),
            message: "CV entry updated successfully"
          }
        else
          render json: {
            success: false,
            errors: @content.errors.full_messages
          }, status: 422
        end
      end
    rescue => e
      render json: {
        success: false,
        errors: [ e.message ]
      }, status: 422
    end
  end

  def update_project
    field_value = case @field
    when "title", "description", "github_url", "project_url"
      params[:value]
    else
      render json: { error: "Invalid field" }, status: 400
      return
    end

    if @content.update(@field => field_value)
      render json: {
        success: true,
        content: @content.send(@field),
        message: "Project updated successfully"
      }
    else
      render json: {
        success: false,
        errors: @content.errors.full_messages
      }, status: 422
    end
  end

  def update_blog_post
    field_value = case @field
    when "title"
      params[:value]
    when "content"
      params[:value]
    else
      render json: { error: "Invalid field" }, status: 400
      return
    end

    if @content.update(@field => field_value)
      render json: {
        success: true,
        content: @content.send(@field),
        message: "Blog post updated successfully"
      }
    else
      render json: {
        success: false,
        errors: @content.errors.full_messages
      }, status: 422
    end
  end
end
