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

    if @cv_entry.save
      redirect_to cv_path, notice: "CV entry was successfully created."
    else
      @cv_entries = CvEntry.ordered
      render "cv/show", status: :unprocessable_entity
    end
  end

  def update
    if @cv_entry.update(cv_entry_params)
      redirect_to cv_path, notice: "CV entry was successfully updated."
    else
      @cv_entries = CvEntry.ordered
      render "cv/show", status: :unprocessable_entity
    end
  end

  def destroy
    @cv_entry.destroy
    redirect_to cv_path, notice: "CV entry was successfully deleted."
  end

  private

  def set_cv_entry
    @cv_entry = CvEntry.find(params[:id])
  end

  def cv_entry_params
    params.require(:cv_entry).permit(:title, :content, :position)
  end
end
