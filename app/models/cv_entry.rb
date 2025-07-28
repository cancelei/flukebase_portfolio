class CvEntry < ApplicationRecord
  has_rich_text :content

  validates :title, presence: true
  validates :content, presence: true
  validates :position, presence: true, uniqueness: true

  scope :ordered, -> { order(:position) }
end
