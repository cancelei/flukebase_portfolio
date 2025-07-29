class SharedEditingController < ApplicationController
  before_action :authenticate_user!
  before_action :set_content_and_field

  def show
    render partial: "shared_editing/edit_form", locals: { content: @content, field: @field }
  end

  def edit
    render partial: "shared_editing/edit_form", locals: { content: @content, field: @field }
  end

  def update
    case @content_type
    when "CvEntry"
      update_cv_entry
    when "PersonalInfo"
      update_personal_info
    when "Project"
      update_project
    when "SiteSetting"
      update_site_setting
    else
      render json: { error: "Unsupported content type: #{@content_type}" }, status: 400
    end
  end

  private

  def set_content_and_field
    @content_type = params[:content_type].camelize
    @content_id = params[:content_id]
    @field = params[:field]

    Rails.logger.debug("Content type: #{@content_type}, Content ID: #{@content_id}, Field: #{@field}")

    case @content_type
    when "CvEntry"
      @content = CvEntry.find(@content_id)
    when "PersonalInfo"
      @content = PersonalInfo.find(@content_id)
    when "Project"
      @content = Project.find(@content_id)
    when "SiteSetting"
      @content = SiteSetting.find_by(key: @content_id) || SiteSetting.find(@content_id)
    else
      Rails.logger.error("Invalid content type: #{@content_type}")
      render json: { error: "Invalid content type: #{@content_type}" }, status: 400
      nil
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("Content not found: #{e.message}")
    render json: { error: "Content not found: #{e.message}" }, status: 404
  end

  def update_personal_info
    field_value = case @field
    when "name", "title", "email", "phone", "location", "website", "linkedin", "twitter", "github"
      params[:value]
    when "summary"
      params[:value]
    else
      render json: { error: "Invalid field" }, status: 400
      return
    end

    begin
      if @field == "summary"
        # Handle ActionText rich content - preserve formatting
        @content.summary = field_value
        if @content.save
          render json: {
            success: true,
            content: @content.summary.body.to_html,
            message: "Personal information updated successfully"
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
            message: "Personal information updated successfully"
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

  def update_cv_entry
    field_value = case @field
    when "title", "company"
      params[:value]
    when "content"
      params[:value]
    when "start_date", "end_date"
      begin
        # Parse date from string (expecting format like "2023-07-01")
        Date.parse(params[:value]) if params[:value].present?
      rescue ArgumentError => e
        render json: { error: "Invalid date format. Please use YYYY-MM-DD format." }, status: 400
        return
      end
    when "current"
      ActiveModel::Type::Boolean.new.cast(params[:value])
    else
      render json: { error: "Invalid field: #{@field}" }, status: 400
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
          # For date fields, return the formatted date range
          response_content = if [ "start_date", "end_date", "current" ].include?(@field)
                             @content.date_range
          else
                             @content.send(@field)
          end

          render json: {
            success: true,
            content: response_content,
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
      Rails.logger.error("Error updating CV entry: #{e.message}")
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

  def update_site_setting
    field_value = case @content.value_type
    when "boolean"
      params[:value] == "true"
    else
      params[:value]
    end

    if @content.update(value: field_value)
      render json: {
        success: true,
        content: @content.value,
        message: "Setting updated successfully"
      }
    else
      render json: {
        success: false,
        errors: @content.errors.full_messages
      }, status: 422
    end
  end
end
