class CvEntry < ApplicationRecord
  has_rich_text :content

  validates :title, presence: true
  validates :content, presence: true
  validates :position, presence: true, uniqueness: true
  validates :entry_type, presence: true, inclusion: {
    in: %w[experience project achievement summary other],
    message: "must be one of: experience, project, achievement, summary, other"
  }

  # Knowledge base callbacks (only for experiences)
  after_save :update_knowledge_base, if: -> { entry_type == "experience" }
  after_destroy :remove_from_knowledge_base, if: -> { entry_type == "experience" }

  scope :ordered, -> { order(:position) }
  scope :by_type, ->(type) { where(entry_type: type) }
  scope :experiences, -> { by_type("experience") }
  scope :projects, -> { by_type("project") }
  scope :achievements, -> { by_type("achievement") }
  scope :summaries, -> { by_type("summary") }

  def display_duration
    return "Present" if current?
    return "" unless start_date && end_date

    duration_months = (end_date.year - start_date.year) * 12 + (end_date.month - start_date.month)
    years = duration_months / 12
    months = duration_months % 12

    result = []
    result << "#{years} #{'year'.pluralize(years)}" if years > 0
    result << "#{months} #{'month'.pluralize(months)}" if months > 0
    result.join(", ")
  end

  def date_range
    return "" unless start_date

    start_str = start_date.strftime("%b %Y")
    end_str = current? ? "Present" : (end_date&.strftime("%b %Y") || "")

    if end_str.present?
      "#{start_str} - #{end_str}"
    else
      start_str
    end
  end

  private

  def update_knowledge_base
    KnowledgeBaseUpdateJob.perform_later("CvEntry", id, "update")
  end

  def remove_from_knowledge_base
    KnowledgeBaseUpdateJob.perform_later("CvEntry", id, "delete")
  end
end
