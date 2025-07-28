class BlogPost < ApplicationRecord
  has_rich_text :content

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, if: -> { slug.blank? }

  scope :published, -> { where(published: true) }
  scope :recent, -> { order(published_at: :desc) }

  private

  def generate_slug
    self.slug = title.parameterize if title.present?
  end
end
