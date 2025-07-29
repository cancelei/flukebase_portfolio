class ResumesController < ApplicationController
  def show
    @personal_info = PersonalInfo.current
    @cv_entries = CvEntry.ordered
    @skills = Skill.ordered
    @educations = Education.ordered
    @certifications = Certification.ordered

    # Group CV entries by type for better organization
    @experiences = @cv_entries.experiences
    @projects = @cv_entries.projects
    @achievements = @cv_entries.achievements

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "resume_#{@personal_info.name&.parameterize || 'cv'}",
               page_size: "A4",
               template: "resumes/show.pdf.erb",
               layout: "pdf.html",
               show_as_html: params[:debug].present?
      end
    end
  end
end
