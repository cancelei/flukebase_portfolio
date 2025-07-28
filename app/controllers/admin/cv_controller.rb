class Admin::CvController < Admin::BaseController
  def show
    @cv_entries = CvEntry.ordered
  end
end
