class Admin::CvEntriesController < Admin::BaseController
  before_action :set_cv_entry, only: [ :index, :edit, :update, :destroy ]

  def index
    @cv_entries = CvEntry.ordered.page(params[:page]).per(20)
  end

  def show
    set_cv_entry
    # CV entry is set by before_action
  end

  def new
    @cv_entry = CvEntry.new
    @next_position = (CvEntry.maximum(:position) || 0) + 1
  end

  def create
    @cv_entry = CvEntry.new(cv_entry_params)

    if @cv_entry.save
      redirect_to admin_cv_entry_path(@cv_entry), notice: "CV entry was successfully created."
    else
      @next_position = (CvEntry.maximum(:position) || 0) + 1
      render :new
    end
  end

  def edit
    # CV entry is set by before_action
  end

  def update
    if @cv_entry.update(cv_entry_params)
      redirect_to admin_cv_entry_path(@cv_entry), notice: "CV entry was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @cv_entry.destroy
    redirect_to admin_cv_entries_path, notice: "CV entry was successfully deleted."
  end

  private

  def set_cv_entry
    @cv_entry = CvEntry.find(params[:id])
  end

  def cv_entry_params
    params.require(:cv_entry).permit(:title, :content, :position)
  end
end
