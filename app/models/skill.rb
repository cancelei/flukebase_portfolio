class Skill < ApplicationRecord
  validates :name, presence: true, uniqueness: { scope: :category }
  validates :category, presence: true
  validates :proficiency_level, presence: true, inclusion: { in: 1..5 }
  validates :position, presence: true, uniqueness: { scope: :category }

  # Knowledge base callbacks
  after_save :update_skills_knowledge_base
  after_destroy :update_skills_knowledge_base

  scope :ordered, -> { order(:category, :position) }
  scope :by_category, ->(cat) { where(category: cat) }
  scope :by_proficiency, ->(level) { where(proficiency_level: level) }

  CATEGORIES = [
    "Programming Languages",
    "Frameworks & Libraries",
    "Databases",
    "Tools & Technologies",
    "Cloud Services",
    "Other"
  ].freeze

  PROFICIENCY_LEVELS = {
    1 => "Beginner",
    2 => "Novice",
    3 => "Intermediate",
    4 => "Advanced",
    5 => "Expert"
  }.freeze

  def proficiency_name
    PROFICIENCY_LEVELS[proficiency_level]
  end

  def proficiency_percentage
    (proficiency_level * 20).to_s
  end

  private

  def update_skills_knowledge_base
    KnowledgeBaseUpdateJob.perform_later("Skills", 0, "update")
  end
end
