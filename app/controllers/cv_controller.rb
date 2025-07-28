class CvController < ApplicationController
  def show
    @cv_entries = CvEntry.ordered
    @cv_entry = CvEntry.new
  end
end
