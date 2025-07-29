class Education < ApplicationRecord
  has_rich_text :achievements

  validates :institution, presence: true
  validates :degree, presence: true
  validates :field_of_study, presence: true
  validates :start_date, presence: true
  validates :position, presence: true, uniqueness: true

  # Knowledge base callbacks
  after_save :update_knowledge_base
  after_destroy :remove_from_knowledge_base

  scope :ordered, -> { order(:position) }
  scope :current, -> { where(current: true) }
  scope :completed, -> { where(current: false) }

  def date_range
    return "" unless start_date

    start_str = start_date.strftime("%Y")
    end_str = current? ? "Present" : (end_date&.strftime("%Y") || "")

    if end_str.present?
      "#{start_str} - #{end_str}"
    else
      start_str
    end
  end

  def full_degree
    "#{degree} in #{field_of_study}"
  end

  def display_gpa
    return "" unless gpa.present?
    "GPA: #{gpa}"
  end

  private

  def update_knowledge_base
    KnowledgeBaseUpdateJob.perform_later("Education", id, "update")
  end

  def remove_from_knowledge_base
    KnowledgeBaseUpdateJob.perform_later("Education", id, "delete")
  end
end
