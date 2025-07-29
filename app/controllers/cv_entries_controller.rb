class CvEntriesController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_cv_entry, only: [ :update, :destroy ]

  def index
    @cv_entries = CvEntry.ordered
    @cv_entry = CvEntry.new
    render "cv/show"
  end

  def show
    @cv_entries = CvEntry.ordered
    @cv_entry = CvEntry.new
    render "cv/show"
  end

  def new
    @cv_entry = CvEntry.new
    @cv_entries = CvEntry.ordered
    render "cv/show"
  end

  def create
    @cv_entry = CvEntry.new(cv_entry_params)

    # Set default entry_type if not provided
    @cv_entry.entry_type ||= "experience"

    # Automatically set position based on intelligent ordering
    if @cv_entry.entry_type == "experience"
      # For experiences, set position based on start date
      # If it's a current position, put it at the beginning
      if @cv_entry.current?
        @cv_entry.position = get_next_position(0)
      elsif @cv_entry.start_date
        # Find entries with the same start month/year
        same_month_entries = CvEntry.experiences
          .where("extract(year from start_date) = ? AND extract(month from start_date) = ?",
                 @cv_entry.start_date.year, @cv_entry.start_date.month)
          .order(:position)

        if same_month_entries.any?
          # If there are entries in the same month, position after them
          last_same_month = same_month_entries.last
          @cv_entry.position = get_next_position(last_same_month.position)
        else
          # Position based on chronological order
          position_before = CvEntry.experiences
            .where("start_date > ?", @cv_entry.start_date)
            .order(start_date: :asc)
            .first

          if position_before
            @cv_entry.position = get_next_position(position_before.position - 1)
          else
            @cv_entry.position = get_next_position(CvEntry.maximum(:position).to_i)
          end
        end
      else
        # If no start date, put at the end
        @cv_entry.position = get_next_position(CvEntry.maximum(:position).to_i)
      end
    else
      # For non-experiences, just put at the end
      @cv_entry.position = get_next_position(CvEntry.maximum(:position).to_i)
    end

    if @cv_entry.save
      redirect_to cv_path, notice: "CV entry was successfully created."
    else
      @cv_entries = CvEntry.ordered
      redirect_to cv_path, alert: @cv_entry.errors.full_messages.join(", ")
    end
  end

  def update
    if @cv_entry.update(cv_entry_params)
      redirect_to cv_path, notice: "CV entry was successfully updated."
    else
      @cv_entries = CvEntry.ordered
      redirect_to cv_path, alert: @cv_entry.errors.full_messages.join(", ")
    end
  end

  def destroy
    @cv_entry.destroy
    redirect_to cv_path, notice: "CV entry was successfully deleted."
  end

  def reorder
    # Ensure we have positions data
    if params[:positions].blank?
      return render json: { error: "No position data provided" }, status: :unprocessable_entity
    end

    # Get the positions array from params
    positions = params[:positions]

    # Get the entries being reordered
    entries = CvEntry.where(id: positions)

    # Group entries by start month/year and current status
    grouped_entries = {}
    current_entries = []

    entries.each do |entry|
      if entry.current?
        current_entries << entry.id.to_s
      elsif entry.start_date
        month_key = "#{entry.start_date.year}-#{entry.start_date.month}"
        grouped_entries[month_key] ||= []
        grouped_entries[month_key] << entry.id.to_s
      end
    end

    # Validate the reordering - only allow reordering within same groups
    valid_reorder = true

    # Check if all entries in positions are from the same group
    if positions.all? { |id| current_entries.include?(id) }
      # All current entries - allowed
      group_type = "current"
    else
      # Check if all entries are from the same month
      month_group = nil

      grouped_entries.each do |month, ids|
        if positions.all? { |id| ids.include?(id) }
          month_group = month
          break
        end
      end

      if month_group.nil?
        valid_reorder = false
        group_type = "mixed"
      else
        group_type = "same_month"
      end
    end

    if valid_reorder
      # Start a transaction to ensure all updates succeed or fail together
      ActiveRecord::Base.transaction do
        # Update each CV entry with its new position
        # We need to find the base position for this group
        base_position = 0

        if group_type == "current"
          # Current entries go at the beginning (position 0)
          base_position = 0
        elsif group_type == "same_month"
          # Find the minimum position of entries in this month group
          base_position = entries.minimum(:position).to_i
        end

        # Update positions
        positions.each_with_index do |id, index|
          CvEntry.find(id).update!(position: base_position + index)
        end
      end

      # Return success response
      render json: { success: true, message: "Positions updated successfully" }
    else
      # Return error for invalid reordering
      render json: {
        error: "Invalid reordering. You can only reorder experiences that are either all current or all started in the same month."
      }, status: :unprocessable_entity
    end
  rescue => e
    # Log the error and return error response
    Rails.logger.error("Error reordering CV entries: #{e.message}")
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_cv_entry
    @cv_entry = CvEntry.find(params[:id])
  end

  def cv_entry_params
    params.require(:cv_entry).permit(:title, :content, :position, :entry_type, :company, :location, :start_date, :end_date, :current)
  end

  # Helper method to get the next available position
  # Ensures we don't have duplicate positions
  def get_next_position(base_position)
    # Find the next available position after the base position
    next_position = base_position + 1

    # Check if this position is already taken
    while CvEntry.where(position: next_position).exists?
      next_position += 1
    end

    next_position
  end
end
