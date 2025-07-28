class Project < ApplicationRecord
  has_many :project_tags, dependent: :destroy
  has_many :tags, through: :project_tags
  has_many_attached :images
  has_rich_text :description

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :source, inclusion: { in: %w[manual flukebase] }

  before_validation :generate_slug, if: -> { slug.blank? }

  scope :published, -> { where(published: true) }
  scope :search, ->(term) { where("title ILIKE ?", "%#{term}%") if term.present? }
  scope :by_tag, ->(tag) { joins(:tags).where(tags: { name: tag }) if tag.present? }

  private

  def generate_slug
    self.slug = title.parameterize if title.present?
  end
end
