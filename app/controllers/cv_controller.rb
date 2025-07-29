class CvController < ApplicationController
  def show
    @personal_info = PersonalInfo.current
    @cv_entries = CvEntry.ordered
    @cv_entry = CvEntry.new
    @skills = Skill.ordered
    @educations = Education.ordered
    @certifications = Certification.ordered

    # Group CV entries by type for better organization
    @experiences = @cv_entries.experiences
    @projects = @cv_entries.projects
    @achievements = @cv_entries.achievements
  end
end
